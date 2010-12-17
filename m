From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] ipv6: remove duplicate neigh_ifdown
Date: Thu, 16 Dec 2010 19:42:54 -0800
Message-ID: <20101216194254.0f7c7e7b@nehalam>
References: <20101216175152.6767d0a7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44182 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579Ab0LQDm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 22:42:56 -0500
In-Reply-To: <20101216175152.6767d0a7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When device is being set to down, neigh_ifdown was being called
twice. Once from addrconf notifier and once from ndisc notifier.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2010-12-16 17:50:26.658169250 -0800
+++ b/net/ipv6/addrconf.c	2010-12-16 17:52:15.227220647 -0800
@@ -2672,7 +2672,6 @@ static int addrconf_ifdown(struct net_de
 	/* Flush routes if device is being removed or it is not loopback */
 	if (how || !(dev->flags & IFF_LOOPBACK))
 		rt6_ifdown(net, dev);
-	neigh_ifdown(&nd_tbl, dev);
 
 	idev = __in6_dev_get(dev);
 	if (idev == NULL)
