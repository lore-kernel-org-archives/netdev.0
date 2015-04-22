From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 iproute2 3/3] mroute: remove invalid check against NLM_F_MULTI
Date: Wed, 22 Apr 2015 10:27:07 +0200
Message-ID: <1429691227-12310-3-git-send-email-nicolas.dichtel@6wind.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CB2312E@AcuExch.aculab.com>
 <1429691227-12310-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com, david.laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54359 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756010AbbDVI1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 04:27:12 -0400
In-Reply-To: <1429691227-12310-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This flag is only for the netlink protocol (multi-part messages), no reason
to reject messages without it.

Note that this flag was removed by the following kernel patches (v3.14)
65886f439ab0 ipmr: fix mfc notification flags
f518338b1603 ip6mr: fix mfc notification flags

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipmroute.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index 13ac892512d0..125a13f8c582 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -67,8 +67,7 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	int family;
 
 	if ((n->nlmsg_type != RTM_NEWROUTE &&
-	     n->nlmsg_type != RTM_DELROUTE) ||
-	    !(n->nlmsg_flags & NLM_F_MULTI)) {
+	     n->nlmsg_type != RTM_DELROUTE)) {
 		fprintf(stderr, "Not a multicast route: %08x %08x %08x\n",
 			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
 		return 0;
-- 
2.2.2
