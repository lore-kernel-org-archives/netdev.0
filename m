From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V4 05/10] skb_array: introduce batch dequeuing
Date: Wed, 10 May 2017 11:36:17 +0800
Message-ID: <1494387382-19916-6-git-send-email-jasowang@redhat.com>
References: <1494387382-19916-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38160 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752088AbdEJDhF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 23:37:05 -0400
In-Reply-To: <1494387382-19916-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/skb_array.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
index 79850b6..35226cd 100644
--- a/include/linux/skb_array.h
+++ b/include/linux/skb_array.h
@@ -97,21 +97,46 @@ static inline struct sk_buff *skb_array_consume(struct skb_array *a)
 	return ptr_ring_consume(&a->ring);
 }
 
+static inline int skb_array_consume_batched(struct skb_array *a,
+					    struct sk_buff **array, int n)
+{
+	return ptr_ring_consume_batched(&a->ring, (void **)array, n);
+}
+
 static inline struct sk_buff *skb_array_consume_irq(struct skb_array *a)
 {
 	return ptr_ring_consume_irq(&a->ring);
 }
 
+static inline int skb_array_consume_batched_irq(struct skb_array *a,
+						struct sk_buff **array, int n)
+{
+	return ptr_ring_consume_batched_irq(&a->ring, (void **)array, n);
+}
+
 static inline struct sk_buff *skb_array_consume_any(struct skb_array *a)
 {
 	return ptr_ring_consume_any(&a->ring);
 }
 
+static inline int skb_array_consume_batched_any(struct skb_array *a,
+						struct sk_buff **array, int n)
+{
+	return ptr_ring_consume_batched_any(&a->ring, (void **)array, n);
+}
+
+
 static inline struct sk_buff *skb_array_consume_bh(struct skb_array *a)
 {
 	return ptr_ring_consume_bh(&a->ring);
 }
 
+static inline int skb_array_consume_batched_bh(struct skb_array *a,
+					       struct sk_buff **array, int n)
+{
+	return ptr_ring_consume_batched_bh(&a->ring, (void **)array, n);
+}
+
 static inline int __skb_array_len_with_tag(struct sk_buff *skb)
 {
 	if (likely(skb)) {
-- 
2.7.4
