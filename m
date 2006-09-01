From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/8] address: Allow address changes while device is administrative down
Date: Fri, 01 Sep 2006 23:40:04 +0200
Message-ID: <20060901214015.026021813@lsx.localdomain>
References: <20060901213957.138695086@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:6289 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751005AbWIAVlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 17:41:44 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv6_add_fix_admin_down
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Same behaviour as IPv4, using IFF_UP is a no-no anyway.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.orig/net/ipv6/addrconf.c	2006-09-01 23:15:24.000000000 +0200
+++ net-2.6.19/net/ipv6/addrconf.c	2006-09-01 23:15:25.000000000 +0200
@@ -1886,9 +1886,6 @@
 	if ((dev = __dev_get_by_index(ifindex)) == NULL)
 		return -ENODEV;
 	
-	if (!(dev->flags&IFF_UP))
-		return -ENETDOWN;
-
 	if ((idev = addrconf_add_dev(dev)) == NULL)
 		return -ENOBUFS;
 
@@ -2922,9 +2919,6 @@
 	if ((dev = __dev_get_by_index(ifindex)) == NULL)
 		return -ENODEV;
 
-	if (!(dev->flags&IFF_UP))
-		return -ENETDOWN;
-
 	if (!valid_lft || (prefered_lft > valid_lft))
 		return -EINVAL;
 


-- 
VGER BF report: H 1.17609e-05
