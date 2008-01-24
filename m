From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 1/1][NETNS] Add missing initialization of nl_info.nl_net in rtm_to_fib6_config()
Date: Thu, 24 Jan 2008 11:32:21 +0100
Message-ID: <20080124103619.032868994@theryb.frec.bull.fr>
References: <20080124103220.265806220@theryb.frec.bull.fr>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@sw.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:44736 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbYAXKhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 05:37:09 -0500
Content-Disposition: inline; filename=route6-finalize-add-netns-to-nl_info-structure.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing initialization of the new nl_info.nl_net field in 
rtm_to_fib6_config(). This will be needed the store network namespace
associated to the fib6_config struct.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/route.c |    1 +
 1 file changed, 1 insertion(+)

Index: net-2.6.25/net/ipv6/route.c
===================================================================
--- net-2.6.25.orig/net/ipv6/route.c
+++ net-2.6.25/net/ipv6/route.c
@@ -1955,6 +1955,7 @@ static int rtm_to_fib6_config(struct sk_
 
 	cfg->fc_nlinfo.pid = NETLINK_CB(skb).pid;
 	cfg->fc_nlinfo.nlh = nlh;
+	cfg->fc_nlinfo.nl_net = skb->sk->sk_net;
 
 	if (tb[RTA_GATEWAY]) {
 		nla_memcpy(&cfg->fc_gateway, tb[RTA_GATEWAY], 16);

-- 
