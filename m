From: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Subject: [PATCH 1/2] net: dm9000: Read GPR, modify and write
Date: Wed, 22 Jan 2014 11:20:12 +0800
Message-ID: <1390360813-29185-1-git-send-email-chris.ruehl@gtsys.com.hk>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Chris Ruehl <chris.ruehl@gtsys.com.hk>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The GPR register should be read, modified and write to
activate the PHY. A simple write 0 to the GPR might override
other register values with needs to keep.
Some codestyle fixes (mostly leading spaces)

Signed-off-by: Chris Ruehl <chris.ruehl@gtsys.com.hk>
---
 drivers/net/ethernet/davicom/dm9000.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 7080ad6..0349b91 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -745,9 +745,9 @@ static const struct ethtool_ops dm9000_ethtool_ops = {
 	.get_link		= dm9000_get_link,
 	.get_wol		= dm9000_get_wol,
 	.set_wol		= dm9000_set_wol,
- 	.get_eeprom_len		= dm9000_get_eeprom_len,
- 	.get_eeprom		= dm9000_get_eeprom,
- 	.set_eeprom		= dm9000_set_eeprom,
+	.get_eeprom_len		= dm9000_get_eeprom_len,
+	.get_eeprom		= dm9000_get_eeprom,
+	.set_eeprom		= dm9000_set_eeprom,
 };
 
 static void dm9000_show_carrier(board_info_t *db,
@@ -795,7 +795,7 @@ dm9000_poll_work(struct work_struct *w)
 		}
 	} else
 		mii_check_media(&db->mii, netif_msg_link(db), 0);
-	
+
 	if (netif_running(ndev))
 		dm9000_schedule_poll(db);
 }
@@ -1286,6 +1286,7 @@ dm9000_open(struct net_device *dev)
 {
 	board_info_t *db = netdev_priv(dev);
 	unsigned long irqflags = db->irq_res->flags & IRQF_TRIGGER_MASK;
+	int gprval;
 
 	if (netif_msg_ifup(db))
 		dev_dbg(db->dev, "enabling %s\n", dev->name);
@@ -1298,9 +1299,15 @@ dm9000_open(struct net_device *dev)
 
 	irqflags |= IRQF_SHARED;
 
+	gprval = ior(db, DM9000_GPR);
+
 	/* GPIO0 on pre-activate PHY, Reg 1F is not set by reset */
-	iow(db, DM9000_GPR, 0);	/* REG_1F bit0 activate phyxcer */
-	mdelay(1); /* delay needs by DM9000B */
+	if (gprval & (1<<0)) {
+		dev_dbg(db->dev, "Activate PHY GPR: 0x%x\n", gprval);
+		gprval = gprval & ~(1<<0);
+		iow(db, DM9000_GPR, gprval);	/* REG_1F bit0 activate phyxcer */
+		mdelay(1); /* delay needs by DM9000B */
+	}
 
 	/* Initialize DM9000 board */
 	dm9000_reset(db);
@@ -1314,7 +1321,7 @@ dm9000_open(struct net_device *dev)
 
 	mii_check_media(&db->mii, netif_msg_link(db), 1);
 	netif_start_queue(dev);
-	
+
 	dm9000_schedule_poll(db);
 
 	return 0;
@@ -1628,7 +1635,7 @@ dm9000_probe(struct platform_device *pdev)
 
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
 		/* try reading from mac */
-		
+
 		mac_src = "chip";
 		for (i = 0; i < 6; i++)
 			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
-- 
1.7.10.4
