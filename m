From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 2/8] skb_array: introduce batch dequeuing
Date: Tue, 21 Mar 2017 12:04:41 +0800
Message-ID: <1490069087-4783-3-git-send-email-jasowang@redhat.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
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

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/skb_array.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
index f4dfade..90e44b9 100644
--- a/include/linux/skb_array.h
+++ b/include/linux/skb_array.h
@@ -97,21 +97,46 @@ static inline struct sk_buff *skb_array_consume(struct skb_array *a)
 	return ptr_ring_consume(&a->ring);
 }
 
+static inline int skb_array_consume_batched(struct skb_array *a,
+					    void **array, int n)
+{
+	return ptr_ring_consume_batched(&a->ring, array, n);
+}
+
 static inline struct sk_buff *skb_array_consume_irq(struct skb_array *a)
 {
 	return ptr_ring_consume_irq(&a->ring);
 }
 
+static inline int skb_array_consume_batched_irq(struct skb_array *a,
+						void **array, int n)
+{
+	return ptr_ring_consume_batched_irq(&a->ring, array, n);
+}
+
 static inline struct sk_buff *skb_array_consume_any(struct skb_array *a)
 {
 	return ptr_ring_consume_any(&a->ring);
 }
 
+static inline int skb_array_consume_batched_any(struct skb_array *a,
+						void **array, int n)
+{
+	return ptr_ring_consume_batched_any(&a->ring, array, n);
+}
+
+
 static inline struct sk_buff *skb_array_consume_bh(struct skb_array *a)
 {
 	return ptr_ring_consume_bh(&a->ring);
 }
 
+static inline int skb_array_consume_batched_bh(struct skb_array *a,
+					       void **array, int n)
+{
+	return ptr_ring_consume_batched_bh(&a->ring, array, n);
+}
+
 static inline int __skb_array_len_with_tag(struct sk_buff *skb)
 {
 	if (likely(skb)) {
-- 
2.7.4
