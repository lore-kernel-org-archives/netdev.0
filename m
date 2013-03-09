From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH] ipv6: remove superfluous nla_data() NULL pointer checks
Date: Sat,  9 Mar 2013 16:57:00 +0100
Message-ID: <1362844620-13035-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:38780 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758389Ab3CIP5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 10:57:11 -0500
Received: by mail-bk0-f42.google.com with SMTP id jk7so1129025bkc.29
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 07:57:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nla_data() cannot return NULL, so these NULL pointer checks are
superfluous.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/ipv6/addrlabel.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index aad6435..6f226c8 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -436,10 +436,7 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	if (!tb[IFAL_ADDRESS])
 		return -EINVAL;
-
 	pfx = nla_data(tb[IFAL_ADDRESS]);
-	if (!pfx)
-		return -EINVAL;
 
 	if (!tb[IFAL_LABEL])
 		return -EINVAL;
@@ -561,10 +558,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
 
 	if (!tb[IFAL_ADDRESS])
 		return -EINVAL;
-
 	addr = nla_data(tb[IFAL_ADDRESS]);
-	if (!addr)
-		return -EINVAL;
 
 	rcu_read_lock();
 	p = __ipv6_addr_label(net, addr, ipv6_addr_type(addr), ifal->ifal_index);
-- 
1.7.10.4
