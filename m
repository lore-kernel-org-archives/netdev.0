From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V3 2/6] skb_array: minor tweak
Date: Thu, 30 Jun 2016 11:52:55 +0800
Message-ID: <1467258779-3539-3-git-send-email-jasowang@redhat.com>
References: <1467258779-3539-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1467258779-3539-1-git-send-email-jasowang@redhat.com>
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
 include/linux/skb_array.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
index 678bfbf..2dd0d1e 100644
--- a/include/linux/skb_array.h
+++ b/include/linux/skb_array.h
@@ -151,12 +151,12 @@ static inline int skb_array_init(struct skb_array *a, int size, gfp_t gfp)
 	return ptr_ring_init(&a->ring, size, gfp);
 }
 
-void __skb_array_destroy_skb(void *ptr)
+static void __skb_array_destroy_skb(void *ptr)
 {
 	kfree_skb(ptr);
 }
 
-int skb_array_resize(struct skb_array *a, int size, gfp_t gfp)
+static inline int skb_array_resize(struct skb_array *a, int size, gfp_t gfp)
 {
 	return ptr_ring_resize(&a->ring, size, gfp, __skb_array_destroy_skb);
 }
-- 
2.7.4
