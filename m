From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] rtl8150: use default MTU of 1500
Date: Fri, 18 Aug 2006 22:15:00 +0200
Message-ID: <20060818201500.GA5152@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:21213 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932295AbWHRUPJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 16:15:09 -0400
To: petkan@users.sourceforge.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rtl8150 (ethernet) driver uses a default MTU of 1540, which causes
all kinds of problems with for example booting off NFS root.  There isn't
really any reason why we shouldn't use the default of 1500.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

Index: linux-2.6.18-rc2/drivers/usb/net/rtl8150.c
===================================================================
--- linux-2.6.18-rc2.orig/drivers/usb/net/rtl8150.c
+++ linux-2.6.18-rc2/drivers/usb/net/rtl8150.c
@@ -867,9 +867,8 @@
 	netdev->hard_start_xmit = rtl8150_start_xmit;
 	netdev->set_multicast_list = rtl8150_set_multicast;
 	netdev->set_mac_address = rtl8150_set_mac_address;
 	netdev->get_stats = rtl8150_netdev_stats;
-	netdev->mtu = RTL8150_MTU;
 	SET_ETHTOOL_OPS(netdev, &ops);
 	dev->intr_interval = 100;	/* 100ms */
 
 	if (!alloc_all_urbs(dev)) {
