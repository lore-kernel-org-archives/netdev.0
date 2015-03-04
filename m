From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 2/8] netfilter: bridge: move nf_bridge_update_protocol to where its used
Date: Thu,  5 Mar 2015 00:52:34 +0100
Message-ID: <1425513160-496-3-git-send-email-fw@strlen.de>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33796 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753170AbbCDXw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 18:52:56 -0500
In-Reply-To: <1425513160-496-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

no need to keep it in a header file.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h | 8 --------
 net/bridge/br_netfilter.c        | 8 ++++++++
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 332ef8a..dd580a9 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -36,14 +36,6 @@ static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
 	}
 }
 
-static inline void nf_bridge_update_protocol(struct sk_buff *skb)
-{
-	if (skb->nf_bridge->mask & BRNF_8021Q)
-		skb->protocol = htons(ETH_P_8021Q);
-	else if (skb->nf_bridge->mask & BRNF_PPPoE)
-		skb->protocol = htons(ETH_P_PPP_SES);
-}
-
 static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 {
 	if (unlikely(skb->nf_bridge->mask & BRNF_PPPoE))
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index e547911..5b3bceb 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -239,6 +239,14 @@ drop:
 	return -1;
 }
 
+static void nf_bridge_update_protocol(struct sk_buff *skb)
+{
+	if (skb->nf_bridge->mask & BRNF_8021Q)
+		skb->protocol = htons(ETH_P_8021Q);
+	else if (skb->nf_bridge->mask & BRNF_PPPoE)
+		skb->protocol = htons(ETH_P_PPP_SES);
+}
+
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
 /* Undo the changes made for ip6tables PREROUTING and continue the
  * bridge PRE_ROUTING hook. */
-- 
2.0.5
