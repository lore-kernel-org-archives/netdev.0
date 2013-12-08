From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next 5/5] ipv6: use ip6_flowinfo helper
Date: Sun,  8 Dec 2013 15:47:01 +0100
Message-ID: <1386514021-11646-5-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:57314 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759243Ab3LHOrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 09:47:14 -0500
In-Reply-To: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/af_inet6.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 4fbdb70..027615a 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -683,8 +683,7 @@ bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb)
 	if (np->rxopt.all) {
 		if ((opt->hop && (np->rxopt.bits.hopopts ||
 				  np->rxopt.bits.ohopopts)) ||
-		    ((IPV6_FLOWINFO_MASK &
-		      *(__be32 *)skb_network_header(skb)) &&
+		    (ip6_flowinfo((struct ipv6hdr *) skb_network_header(skb)) &&
 		     np->rxopt.bits.rxflow) ||
 		    (opt->srcrt && (np->rxopt.bits.srcrt ||
 		     np->rxopt.bits.osrcrt)) ||
-- 
1.8.4.3
