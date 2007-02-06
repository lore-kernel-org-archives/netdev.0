From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/7] sky2: TSO support for EC_U
Date: Tue, 06 Feb 2007 10:45:41 -0800
Message-ID: <20070206184855.063544000@linux-foundation.org>
References: <20070206184538.675048000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45614 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965239AbXBFSxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 13:53:20 -0500
Content-Disposition: inline; filename=sky2-ec-u-tso.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Yukon EC_U chipset apparently supports TSO but only for non-Jumbo
frame sizes because it lacks a Ram buffer.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- sky2-dev.orig/drivers/net/sky2.c	2007-02-06 10:44:19.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-06 10:44:21.000000000 -0800
@@ -1895,8 +1895,9 @@
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
 
+	/* TSO on Yukon Ultra and MTU > 1500 not supported */
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U && new_mtu > ETH_DATA_LEN)
-		return -EINVAL;
+		dev->features &= ~NETIF_F_TSO;
 
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
@@ -3350,11 +3351,9 @@
 
 	sky2->port = port;
 
-	if (hw->chip_id != CHIP_ID_YUKON_EC_U)
-		dev->features |= NETIF_F_TSO;
+	dev->features |= NETIF_F_TSO | NETIF_F_IP_CSUM | NETIF_F_SG;
 	if (highmem)
 		dev->features |= NETIF_F_HIGHDMA;
-	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 
 #ifdef SKY2_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;

--
Stephen Hemminger <shemminger@linux-foundation.org>

