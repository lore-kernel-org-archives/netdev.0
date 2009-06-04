From: Riccardo Ghetta <birrachiara@tin.it>
Subject: [PATCH 1/3] sis190: better message on unknown PHY
Date: Thu, 4 Jun 2009 21:04:55 +0200
Message-ID: <20090604190455.GA31545@localhost>
References: <cover.1244141444.git.birrachiara@tin.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp1.tin.it ([212.216.176.141]:35633 "EHLO vsmtp1.tin.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257AbZFDTEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2009 15:04:54 -0400
Content-Disposition: inline
In-Reply-To: <cover.1244141444.git.birrachiara@tin.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Riccardo Ghetta <birrachiara@tin.it>
---
 drivers/net/sis190.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 55ccd51..46de808 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -347,7 +347,7 @@ static struct {
 	u32 msg_enable;
 } debug = { -1 };
 
-MODULE_DESCRIPTION("SiS sis190 Gigabit Ethernet driver");
+MODULE_DESCRIPTION("SiS sis190/191 Gigabit Ethernet driver");
 module_param(rx_copybreak, int, 0);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 module_param_named(debug, debug.msg_enable, int, 0);
@@ -1315,12 +1315,15 @@ static void sis190_init_phy(struct net_device *dev, struct sis190_private *tp,
 			((mii_status & (BMSR_100FULL | BMSR_100HALF)) ?
 				LAN : HOME) : p->type;
 		tp->features |= p->feature;
-	} else
+		net_probe(tp, KERN_INFO "%s: %s transceiver at address %d.\n",
+			pci_name(tp->pci_dev), p->name, phy_id);
+	} else {
 		phy->type = UNKNOWN;
-
-	net_probe(tp, KERN_INFO "%s: %s transceiver at address %d.\n",
-		  pci_name(tp->pci_dev),
-		  (phy->type == UNKNOWN) ? "Unknown PHY" : p->name, phy_id);
+		net_probe(tp, KERN_INFO
+			"%s: unknown PHY 0x%x:0x%x transceiver at address %d\n",
+			pci_name(tp->pci_dev),
+			phy->id[0], (phy->id[1] & 0xfff0), phy_id);
+	}
 }
 
 static void sis190_mii_probe_88e1111_fixup(struct sis190_private *tp)
-- 
1.6.2.4

