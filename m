From: pablo@netfilter.org
Subject: [PATCH 4/5] netfilter: xtables: collapse conditions in xt_ecn
Date: Wed, 28 Dec 2011 14:39:32 +0100
Message-ID: <1325079573-6120-5-git-send-email-pablo@netfilter.org>
References: <1325079573-6120-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jengelh@medozas.de,
	kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59529 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753789Ab1L1Nju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 08:39:50 -0500
In-Reply-To: <1325079573-6120-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

One simplification of an if clause.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_ecn.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/xt_ecn.c b/net/netfilter/xt_ecn.c
index 6ccc35d..3c831a8 100644
--- a/net/netfilter/xt_ecn.c
+++ b/net/netfilter/xt_ecn.c
@@ -37,9 +37,8 @@ static bool match_tcp(const struct sk_buff *skb, struct xt_action_param *par)
 	 * be good citizens.
 	 */
 	th = skb_header_pointer(skb, par->thoff, sizeof(_tcph), &_tcph);
-	if (th == NULL) {
+	if (th == NULL)
 		return false;
-	}
 
 	if (einfo->operation & XT_ECN_OP_MATCH_ECE) {
 		if (einfo->invert & XT_ECN_OP_MATCH_ECE) {
@@ -75,14 +74,12 @@ static bool ecn_mt4(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_ecn_info *info = par->matchinfo;
 
-	if (info->operation & XT_ECN_OP_MATCH_IP)
-		if (!match_ip(skb, info))
-			return false;
+	if (info->operation & XT_ECN_OP_MATCH_IP && !match_ip(skb, info))
+		return false;
 
-	if (info->operation & (XT_ECN_OP_MATCH_ECE | XT_ECN_OP_MATCH_CWR)) {
-		if (!match_tcp(skb, par))
-			return false;
-	}
+	if (info->operation & (XT_ECN_OP_MATCH_ECE | XT_ECN_OP_MATCH_CWR) &&
+	    !match_tcp(skb, par))
+		return false;
 
 	return true;
 }
-- 
1.7.7.3
