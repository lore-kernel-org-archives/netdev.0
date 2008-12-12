From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: eliminate warning from NETIF_F_UFO on bridge
Date: Fri, 12 Dec 2008 10:27:08 -0800
Message-ID: <20081212102708.3f8dfbff@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58555 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758628AbYLLS1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 13:27:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge device always causes a warning because when it is first created
it has the no checksum flag set along with all the segmentation/fragmentation
offload bits.  The code in register_netdevice incorrectly checks for only
hardware checksum bit and ignores no checksum bit.

Similar code is already in 2.6.28:
   commit b63365a2d60268a3988285d6c3c6003d7066f93a
   net: Fix disjunct computation of netdev features

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
Patch against 2.6.27.y

--- a/net/core/dev.c	2008-12-09 09:52:03.226334984 -0800
+++ b/net/core/dev.c	2008-12-09 09:53:15.527751814 -0800
@@ -3990,7 +3990,7 @@ int register_netdevice(struct net_device
 		dev->features &= ~NETIF_F_TSO;
 	}
 	if (dev->features & NETIF_F_UFO) {
-		if (!(dev->features & NETIF_F_HW_CSUM)) {
+		if (!(dev->features & NETIF_F_GEN_CSUM)) {
 			printk(KERN_ERR "%s: Dropping NETIF_F_UFO since no "
 					"NETIF_F_HW_CSUM feature.\n",
 							dev->name);
