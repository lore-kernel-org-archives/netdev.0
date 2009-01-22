From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 4/4]bnx2x: Carrier off first call
Date: Thu, 22 Jan 2009 15:37:48 +0200
Message-ID: <1232631468.29087.31.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4965 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753803AbZAVNjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 08:39:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call carrier off should not be called after register_netdev since after
register netdev open can be called at any time followed by an interrupt that
will set it to carrier_on and the probe will resume control and set it to off

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 707c4bb..fbd7165 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9827,6 +9827,8 @@ static int bnx2x_open(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
+	netif_carrier_off(dev);
+
 	bnx2x_set_power_state(bp, PCI_D0);
 
 	return bnx2x_nic_load(bp, LOAD_OPEN);
@@ -10332,8 +10334,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		goto init_one_exit;
 	}
 
-	netif_carrier_off(dev);
-
 	bp->common.name = board_info[ent->driver_data].name;
 	printk(KERN_INFO "%s: %s (%c%d) PCI-E x%d %s found at mem %lx,"
 	       " IRQ %d, ", dev->name, bp->common.name,
-- 
1.5.4.3




