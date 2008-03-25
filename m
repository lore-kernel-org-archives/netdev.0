From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: Fix multicast device ioctl checks
Date: Tue, 25 Mar 2008 13:54:53 +0100
Message-ID: <47E8F61D.8040403@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020706040801040902020707"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep32-int.chello.at ([62.179.121.50]:36964 "EHLO
	viefep32-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335AbYCYMzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 08:55:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020706040801040902020707
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------020706040801040902020707
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 33fb000e9d0b9b20c226383ce775f06fdcd426bc
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Mar 25 13:53:52 2008 +0100

    [NET]: Fix multicast device ioctl checks
    
    SIOCADDMULTI/SIOCDELMULTI check whether the driver has a set_multicast_list
    method to determine whether it supports multicast. Drivers implementing
    secondary unicast support use set_rx_mode however.
    
    Check for both dev->set_multicast_mode and dev->set_rx_mode to determine
    multicast capabilities.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index fcdf03c..460e7f9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3329,7 +3329,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			return -EOPNOTSUPP;
 
 		case SIOCADDMULTI:
-			if (!dev->set_multicast_list ||
+			if ((!dev->set_multicast_list && !dev->set_rx_mode) ||
 			    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
 				return -EINVAL;
 			if (!netif_device_present(dev))
@@ -3338,7 +3338,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 					  dev->addr_len, 1);
 
 		case SIOCDELMULTI:
-			if (!dev->set_multicast_list ||
+			if ((!dev->set_multicast_list && !dev->set_rx_mode) ||
 			    ifr->ifr_hwaddr.sa_family != AF_UNSPEC)
 				return -EINVAL;
 			if (!netif_device_present(dev))

--------------020706040801040902020707--
