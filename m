From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/5] netfilter: reset nf_trace in nf_reset
Date: Thu,  4 Apr 2013 14:56:05 +0200
Message-ID: <1365080169-6880-2-git-send-email-pablo@netfilter.org>
References: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40147 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760839Ab3DDM4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 08:56:40 -0400
In-Reply-To: <1365080169-6880-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

We forgot to clear the nf_trace of sk_buff in nf_reset,
When we use veth device, this nf_trace information will
be leaked from one net namespace to another net namespace.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/skbuff.h |    3 +++
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
1.7.10.4
