From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ip6mr: fix rtm_family of rtnl msg
Date: Tue,  4 Dec 2012 12:01:49 +0100
Message-ID: <1354618909-15631-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, kaber@trash.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56587 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab2LDLCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 06:02:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We talk about IPv6, hence the family is RTNL_FAMILY_IP6MR!
rtnl_register() is already called with RTNL_FAMILY_IP6MR.

The bug is here since the beginning of this function (commit 5b285cac3570).

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6mr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f7c7c63..940aa52 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2212,7 +2212,7 @@ static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 		return -EMSGSIZE;
 
 	rtm = nlmsg_data(nlh);
-	rtm->rtm_family   = RTNL_FAMILY_IPMR;
+	rtm->rtm_family   = RTNL_FAMILY_IP6MR;
 	rtm->rtm_dst_len  = 128;
 	rtm->rtm_src_len  = 128;
 	rtm->rtm_tos      = 0;
-- 
1.8.0.1
