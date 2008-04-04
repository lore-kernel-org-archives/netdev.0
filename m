From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 4 Apr 2008 02:33:59 -0400
Message-ID: <20080404063359.GA13309@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:45114 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752928AbYDDGeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 02:34:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will have another batch to send in the next day or so, including a
notable forcedeth fix.

Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 drivers/net/forcedeth.c         |    5 ++---
 drivers/net/phy/marvell.c       |    2 --
 drivers/net/tokenring/olympic.c |    6 +++---
 drivers/net/tulip/tulip_core.c  |    1 -
 4 files changed, 5 insertions(+), 9 deletions(-)

Adrian Bunk (1):
      net/tokenring/olympic.c section fixes

Al Viro (1):
      fix endian lossage in forcedeth

Chuck Ebbert (1):
      NET: remove support for Davicom 9102 from the Tulip driver

Harvey Harrison (1):
      net: marvell.c fix sparse shadowed variable warning

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 980c2c2..419f533 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2112,9 +2112,8 @@ static inline void nv_tx_flip_ownership(struct net_device *dev)
 
 	np->tx_pkts_in_progress--;
 	if (np->tx_change_owner) {
-		__le32 flaglen = le32_to_cpu(np->tx_change_owner->first_tx_desc->flaglen);
-		flaglen |= NV_TX2_VALID;
-		np->tx_change_owner->first_tx_desc->flaglen = cpu_to_le32(flaglen);
+		np->tx_change_owner->first_tx_desc->flaglen |=
+			cpu_to_le32(NV_TX2_VALID);
 		np->tx_pkts_in_progress++;
 
 		np->tx_change_owner = np->tx_change_owner->next_tx_ctx;
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 3353991..32a8503 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -211,8 +211,6 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	}
 
 	if (phydev->interface == PHY_INTERFACE_MODE_SGMII) {
-		int temp;
-
 		temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
 		if (temp < 0)
 			return temp;
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index 433c994..db4ca4f 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -117,7 +117,7 @@
  * Official releases will only have an a.b.c version number format. 
  */
 
-static char version[] __devinitdata = 
+static char version[] =
 "Olympic.c v1.0.5 6/04/02 - Peter De Schrijver & Mike Phillips" ; 
 
 static char *open_maj_error[]  = {"No error", "Lobe Media Test", "Physical Insertion",
@@ -290,7 +290,7 @@ op_disable_dev:
 	return i;
 }
 
-static int __devinit olympic_init(struct net_device *dev)
+static int olympic_init(struct net_device *dev)
 {
     	struct olympic_private *olympic_priv;
 	u8 __iomem *olympic_mmio, *init_srb,*adapter_addr;
@@ -434,7 +434,7 @@ static int __devinit olympic_init(struct net_device *dev)
 
 }
 
-static int __devinit olympic_open(struct net_device *dev) 
+static int olympic_open(struct net_device *dev)
 {
 	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio,*init_srb;
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 82f404b..4443f0f 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -231,7 +231,6 @@ static struct pci_device_id tulip_pci_tbl[] = {
 	{ 0x11F6, 0x9881, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMPEX9881 },
 	{ 0x8086, 0x0039, PCI_ANY_ID, PCI_ANY_ID, 0, 0, I21145 },
 	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
-	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
 	{ 0x1113, 0x1216, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x1113, 0x1217, PCI_ANY_ID, PCI_ANY_ID, 0, 0, MX98715 },
 	{ 0x1113, 0x9511, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
