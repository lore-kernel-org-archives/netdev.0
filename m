From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ipv4: fix route mark sparse warning
Date: Wed, 10 Oct 2012 11:27:25 -0700
Message-ID: <20121010112725.57a6f4a6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47550 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756941Ab2JJS2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 14:28:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse complains about RTA_MARK which is should be host order according
to include file and usage in iproute.

net/ipv4/route.c:2223:46: warning: incorrect type in argument 3 (different base types)
net/ipv4/route.c:2223:46:    expected restricted __be32 [usertype] value
net/ipv4/route.c:2223:46:    got unsigned int [unsigned] [usertype] flowic_mark

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/route.c	2012-10-09 10:35:03.323140263 -0700
+++ b/net/ipv4/route.c	2012-10-10 10:59:08.774798362 -0700
@@ -2220,7 +2220,7 @@ static int rt_fill_info(struct net *net,
 		goto nla_put_failure;
 
 	if (fl4->flowi4_mark &&
-	    nla_put_be32(skb, RTA_MARK, fl4->flowi4_mark))
+	    nla_put_u32(skb, RTA_MARK, fl4->flowi4_mark))
 		goto nla_put_failure;
 
 	error = rt->dst.error;
