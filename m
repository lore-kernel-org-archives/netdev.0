From: Riccardo Ghetta <birrachiara@tin.it>
Subject: [PATCH 3/3] sis190: better message on unknown PHY
Date: Tue, 2 Jun 2009 09:53:37 +0000 (UTC)
Message-ID: <20090603095354.GA15649@localhost>
References: <cover.1244012631.git.birrachiara@tin.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp14.tin.it ([212.216.176.118]:59892 "EHLO vsmtp14.tin.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752207AbZFBJxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 05:53:20 -0400
Date: Wed, 3 Jun 2009 11:53:54 +0200
Content-Disposition: inline
In-Reply-To: <cover.1244012631.git.birrachiara@tin.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Riccardo Ghetta <birrachiara@tin.it>
---
 drivers/net/sis190.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 8322e28..a69f3d2 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -348,7 +348,7 @@ static struct {
 	u32 msg_enable;
 } debug = { -1 };
 
-MODULE_DESCRIPTION("SiS sis190 Gigabit Ethernet driver");
+MODULE_DESCRIPTION("SiS sis190/191 Gigabit Ethernet driver");
 module_param(rx_copybreak, int, 0);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 module_param_named(debug, debug.msg_enable, int, 0);
@@ -1329,12 +1329,15 @@ static void sis190_init_phy(struct net_device *dev, struct sis190_private *tp,
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

