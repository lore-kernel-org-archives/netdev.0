From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V3 2/9] skb_array: introduce skb_array_unconsume
Date: Wed, 10 May 2017 10:37:54 +0800
Message-ID: <1494383881-6811-3-git-send-email-jasowang@redhat.com>
References: <1494383881-6811-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494383881-6811-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/skb_array.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
index f4dfade..79850b6 100644
--- a/include/linux/skb_array.h
+++ b/include/linux/skb_array.h
@@ -156,6 +156,12 @@ static void __skb_array_destroy_skb(void *ptr)
 	kfree_skb(ptr);
 }
 
+static inline void skb_array_unconsume(struct skb_array *a,
+				       struct sk_buff **skbs, int n)
+{
+	ptr_ring_unconsume(&a->ring, (void **)skbs, n, __skb_array_destroy_skb);
+}
+
 static inline int skb_array_resize(struct skb_array *a, int size, gfp_t gfp)
 {
 	return ptr_ring_resize(&a->ring, size, gfp, __skb_array_destroy_skb);
-- 
2.7.4
