From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: fix checksum flag
Date: Thu, 14 Aug 2008 18:49:09 -0400
Message-ID: <48A4B665.5020802@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070808040107040404020202"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:16698 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbYHOB6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 21:58:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070808040107040404020202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the checksum feature advertised in device flags. The 
hardware support TCP/UDP over IPv4 and TCP/UDP over IPv6 (without IPv6 
extension headers). However, the kernel feature flags do not distinguish 
  IPv6 with/without extension headers.

Therefore, the driver needs to use NETIF_F_IP_CSUM instead of 
NETIF_F_HW_CSUM since the latter includes all IPv6 packets.

A future patch can created to check for extension headers and perform 
software checksum calculation.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

--------------070808040107040404020202
Content-Type: text/plain;
 name="patch-forcedeth-ipv4csum"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-ipv4csum"

--- old/drivers/net/forcedeth.c	2008-08-14 18:37:11.000000000 -0400
+++ new/drivers/net/forcedeth.c	2008-08-14 18:37:05.000000000 -0400
@@ -5522,7 +5522,7 @@
 	if (id->driver_data & DEV_HAS_CHECKSUM) {
 		np->rx_csum = 1;
 		np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
-		dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
+		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		dev->features |= NETIF_F_TSO;
 	}
 
@@ -5835,7 +5835,7 @@
 
 	dev_printk(KERN_INFO, &pci_dev->dev, "%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
 		   dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
-		   dev->features & (NETIF_F_HW_CSUM | NETIF_F_SG) ?
+		   dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
 		   	"csum " : "",
 		   dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
 		   	"vlan " : "",

--------------070808040107040404020202--
