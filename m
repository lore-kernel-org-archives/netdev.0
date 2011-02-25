From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 6/7] ipv6: ignore rtnl_unicast() return code
Date: Fri, 25 Feb 2011 16:45:20 +0100
Message-ID: <1298648721-3026-6-git-send-email-hagen@jauu.net>
References: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Cc: fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57596 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755579Ab1BYPxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 10:53:25 -0500
In-Reply-To: <1298648721-3026-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl_unicast() return value is not of interest, we can silently ignore
it, save some instructions and four byte on the stack.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/ipv6/ip6mr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 0e1d53b..618f67cc 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1039,7 +1039,6 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 
 	while((skb = __skb_dequeue(&uc->mfc_un.unres.unresolved))) {
 		if (ipv6_hdr(skb)->version == 0) {
-			int err;
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
 
 			if (__ip6mr_fill_mroute(mrt, skb, c, NLMSG_DATA(nlh)) > 0) {
@@ -1050,7 +1049,7 @@ static void ip6mr_cache_resolve(struct net *net, struct mr6_table *mrt,
 				skb_trim(skb, nlh->nlmsg_len);
 				((struct nlmsgerr *)NLMSG_DATA(nlh))->error = -EMSGSIZE;
 			}
-			err = rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
+			rtnl_unicast(skb, net, NETLINK_CB(skb).pid);
 		} else
 			ip6_mr_forward(net, mrt, skb, c);
 	}
-- 
1.7.2.3

