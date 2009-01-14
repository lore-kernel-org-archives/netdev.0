From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 21/34]bnx2x: Carrier off first call
Date: Wed, 14 Jan 2009 18:43:44 +0200
Message-ID: <1231951424.11301.142.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2685 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763684AbZANQon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call carrier off should not be called after register_netdev since after
register netdef open can be called at any time followed by an interrupt that
will set it to carrier_on and the probe will resume control and set it to off

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 84c8aeb..967f4dc 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9815,6 +9815,8 @@ static int bnx2x_open(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
+	netif_carrier_off(dev);
+
 	bnx2x_set_power_state(bp, PCI_D0);
 
 	return bnx2x_nic_load(bp, LOAD_OPEN);
@@ -10322,8 +10324,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		goto init_one_exit;
 	}
 
-	netif_carrier_off(dev);
-
 	bp->common.name = board_info[ent->driver_data].name;
 	printk(KERN_INFO "%s: %s (%c%d) PCI-E x%d %s found at mem %lx,"
 	       " IRQ %d, ", dev->name, bp->common.name,
-- 
1.5.4.3




