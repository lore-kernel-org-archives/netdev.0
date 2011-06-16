From: kaber@trash.net
Subject: [PATCH 3/6] netfilter: ipt_ecn: fix protocol check in ecn_mt_check()
Date: Thu, 16 Jun 2011 21:41:38 +0200
Message-ID: <1308253301-29894-4-git-send-email-kaber@trash.net>
References: <1308253301-29894-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1308253301-29894-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Check for protocol inversion in ecn_mt_check() and remove the
unnecessary runtime check for IPPROTO_TCP in ecn_mt().

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_ecn.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ecn.c b/net/ipv4/netfilter/ipt_ecn.c
index af6e9c7..aaa85be 100644
--- a/net/ipv4/netfilter/ipt_ecn.c
+++ b/net/ipv4/netfilter/ipt_ecn.c
@@ -76,8 +76,6 @@ static bool ecn_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			return false;
 
 	if (info->operation & (IPT_ECN_OP_MATCH_ECE|IPT_ECN_OP_MATCH_CWR)) {
-		if (ip_hdr(skb)->protocol != IPPROTO_TCP)
-			return false;
 		if (!match_tcp(skb, info, &par->hotdrop))
 			return false;
 	}
@@ -97,7 +95,7 @@ static int ecn_mt_check(const struct xt_mtchk_param *par)
 		return -EINVAL;
 
 	if (info->operation & (IPT_ECN_OP_MATCH_ECE|IPT_ECN_OP_MATCH_CWR) &&
-	    ip->proto != IPPROTO_TCP) {
+	    (ip->proto != IPPROTO_TCP || ip->invflags & IPT_INV_PROTO)) {
 		pr_info("cannot match TCP bits in rule for non-tcp packets\n");
 		return -EINVAL;
 	}
-- 
1.7.2.3

