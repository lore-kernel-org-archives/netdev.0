From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V4 4/6] skb_array: add wrappers for resizing
Date: Thu, 30 Jun 2016 14:45:34 +0800
Message-ID: <1467269136-8082-5-git-send-email-jasowang@redhat.com>
References: <1467269136-8082-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1467269136-8082-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/skb_array.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
index 2dd0d1e..f4dfade 100644
--- a/include/linux/skb_array.h
+++ b/include/linux/skb_array.h
@@ -161,6 +161,15 @@ static inline int skb_array_resize(struct skb_array *a, int size, gfp_t gfp)
 	return ptr_ring_resize(&a->ring, size, gfp, __skb_array_destroy_skb);
 }
 
+static inline int skb_array_resize_multiple(struct skb_array **rings,
+					    int nrings, int size, gfp_t gfp)
+{
+	BUILD_BUG_ON(offsetof(struct skb_array, ring));
+	return ptr_ring_resize_multiple((struct ptr_ring **)rings,
+					nrings, size, gfp,
+					__skb_array_destroy_skb);
+}
+
 static inline void skb_array_cleanup(struct skb_array *a)
 {
 	ptr_ring_cleanup(&a->ring, __skb_array_destroy_skb);
-- 
2.7.4
