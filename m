From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 1/2] netfilter: reset nf_trace in nf_reset
Date: Fri, 22 Mar 2013 13:48:41 +0800
Message-ID: <1363931322-2286-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We forgot to clear the nf_trace of sk_buff in nf_reset,
When we use veth device, this nf_trace information will
be leaked from one net namespace to another net namespace.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/linux/skbuff.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 441f5bf..72b3967 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2641,6 +2641,9 @@ static inline void nf_reset(struct sk_buff *skb)
 	nf_bridge_put(skb->nf_bridge);
 	skb->nf_bridge = NULL;
 #endif
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
+	skb->nf_trace = 0;
+#endif
 }
 
 /* Note: This doesn't put any conntrack and bridge info in dst. */
-- 
1.7.11.7

