From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 3/4]bnx2x: Calling netif_carrier_off at the end of the
 probe
Date: Mon, 03 Nov 2008 18:11:22 +0200
Message-ID: <1225728682.14568.12.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3896 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755822AbYKCQLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 11:11:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_carrier_off was called too early at the probe. In case of failure
or simply bad timing, this can cause a fatal error since linkwatch_event
might run too soon.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 61152e1..5b013d8 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10206,8 +10206,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 
-	netif_carrier_off(dev);
-
 	bp = netdev_priv(dev);
 	bp->msglevel = debug;
 
@@ -10231,6 +10229,8 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		goto init_one_exit;
 	}
 
+	netif_carrier_off(dev);
+
 	bp->common.name = board_info[ent->driver_data].name;
 	printk(KERN_INFO "%s: %s (%c%d) PCI-E x%d %s found at mem %lx,"
 	       " IRQ %d, ", dev->name, bp->common.name,
-- 
1.5.4.3




