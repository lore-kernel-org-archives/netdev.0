From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/1] ipv6 addrlabel: permit deletion of labels assigned to removed dev
Date: Fri,  7 May 2010 23:31:33 +0200
Message-ID: <1273267893-22485-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:47331 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758617Ab0EGVc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 17:32:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

as addrlabels with an interface index are left alone when the
interface gets removed this results in addrlabels that can no
longer be removed.

Restrict validation of index to adding new addrlabels.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/addrlabel.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 6ff73c4..8342296 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -421,10 +421,6 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 	    ifal->ifal_prefixlen > 128)
 		return -EINVAL;
 
-	if (ifal->ifal_index &&
-	    !__dev_get_by_index(net, ifal->ifal_index))
-		return -EINVAL;
-
 	if (!tb[IFAL_ADDRESS])
 		return -EINVAL;
 
@@ -440,6 +436,10 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	switch(nlh->nlmsg_type) {
 	case RTM_NEWADDRLABEL:
+		if (ifal->ifal_index &&
+		    !__dev_get_by_index(net, ifal->ifal_index))
+			return -EINVAL;
+
 		err = ip6addrlbl_add(net, pfx, ifal->ifal_prefixlen,
 				     ifal->ifal_index, label,
 				     nlh->nlmsg_flags & NLM_F_REPLACE);
-- 
1.6.4.4

