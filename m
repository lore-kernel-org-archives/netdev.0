From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/16] 8139too: Support RX-FCS flag.
Date: Fri, 24 Feb 2012 02:13:03 -0800
Message-ID: <1330078389-8203-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34282 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756833Ab2BXKNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:17 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to pass the Ethernet FCS on up
the stack, and is useful when sniffing networks.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 drivers/net/ethernet/realtek/8139too.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 1b9a090..abd6aca 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -1023,6 +1023,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	dev->vlan_features = dev->features;
 
 	dev->hw_features |= NETIF_F_RXALL;
+	dev->hw_features |= NETIF_F_RXFCS;
 
 	dev->irq = pdev->irq;
 
@@ -1970,7 +1971,10 @@ static int rtl8139_rx(struct net_device *dev, struct rtl8139_private *tp,
 		/* read size+status of next frame from DMA ring buffer */
 		rx_status = le32_to_cpu (*(__le32 *) (rx_ring + ring_offset));
 		rx_size = rx_status >> 16;
-		pkt_size = rx_size - 4;
+		if (likely(!(dev->features & NETIF_F_RXFCS)))
+			pkt_size = rx_size - 4;
+		else
+			pkt_size = rx_size;
 
 		netif_dbg(tp, rx_status, dev, "%s() status %04x, size %04x, cur %04x\n",
 			  __func__, rx_status, rx_size, cur_rx);
-- 
1.7.7.6
