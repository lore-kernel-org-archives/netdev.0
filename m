From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 4/5] forcedeth: fix checksum flag
Date: Wed, 20 Aug 2008 16:34:37 -0700
Message-ID: <200808202334.m7KNYbpF005035@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	aabdulla@nvidia.com, jgarzik@pobox.com, manfred@colorfullife.com,
	stable@kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36225 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755820AbYHTXf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 19:35:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>

Fix the checksum feature advertised in device flags.  The hardware support
TCP/UDP over IPv4 and TCP/UDP over IPv6 (without IPv6 extension headers). 
However, the kernel feature flags do not distinguish IPv6 with/without
extension headers.

Therefore, the driver needs to use NETIF_F_IP_CSUM instead of
NETIF_F_HW_CSUM since the latter includes all IPv6 packets.

A future patch can be created to check for extension headers and perform
software checksum calculation.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Cc: Manfred Spraul <manfred@colorfullife.com
Cc: <stable@kernel.org>		[2.6.25.x, 2.6.26.x]
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/forcedeth.c~forcedeth-fix-checksum-flag drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-fix-checksum-flag
+++ a/drivers/net/forcedeth.c
@@ -5530,7 +5530,7 @@ static int __devinit nv_probe(struct pci
 	if (id->driver_data & DEV_HAS_CHECKSUM) {
 		np->rx_csum = 1;
 		np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
-		dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
+		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		dev->features |= NETIF_F_TSO;
 	}
 
@@ -5843,7 +5843,7 @@ static int __devinit nv_probe(struct pci
 
 	dev_printk(KERN_INFO, &pci_dev->dev, "%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
 		   dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
-		   dev->features & (NETIF_F_HW_CSUM | NETIF_F_SG) ?
+		   dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
 		   	"csum " : "",
 		   dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
 		   	"vlan " : "",
_
