From: Joseph CHANG <josright123@gmail.com>
Subject: [PATCH 2/2] ethernet: dm9000 driver: davicom: upgrade driver: 3rd trial patch2
Date: Wed, 27 Mar 2013 20:09:28 +0800
Message-ID: <1364386168-12503-2-git-send-email-josright123@gmail.com>
References: <1364386168-12503-1-git-send-email-josright123@gmail.com>
Cc: linux-kernel@vger.kernel.org, Joseph CHANG <josright123@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Matthew Leach <matthew@mattleach.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joseph CHANG <joseph_chang@davicom.com.tw>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364386168-12503-1-git-send-email-josright123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixing bug for DM9000B(DSP) patch2

Tested to Davicom DM9000E, DM9000A, DM9000B(DSP),
and DM9000C(DSP) patch2

Signed-off-by: Joseph CHANG <josright123@gmail.com>
---
 drivers/net/ethernet/davicom/dm9000.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 9dd4bd6..a5cd4ad 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -269,9 +269,7 @@ static void dm9000_msleep(board_info_t *db, unsigned int ms)
 		msleep(ms);
 }
 
-/*
- *   Read a word from phyxcer
- */
+/* Read a word from phyxcer */
 static int
 dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 {
@@ -282,7 +280,7 @@ dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 
 	mutex_lock(&db->addr_lock);
 
-	spin_lock_irqsave(&db->lock,flags);
+	spin_lock_irqsave(&db->lock, flags);
 
 	/* Save previous register address */
 	reg_save = readb(db->io_addr);
@@ -290,14 +288,15 @@ dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 	/* Fill the phyxcer register into REG_0C */
 	iow(db, DM9000_EPAR, DM9000_PHY | reg);
 
-	iow(db, DM9000_EPCR, EPCR_ERPRR | EPCR_EPOS);	/* Issue phyxcer read command */
+	/* Issue phyxcer read command */
+	iow(db, DM9000_EPCR, EPCR_ERPRR | EPCR_EPOS);
 
 	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock,flags);
+	spin_unlock_irqrestore(&db->lock, flags);
 
 	dm9000_msleep(db, 1);		/* Wait read complete */
 
-	spin_lock_irqsave(&db->lock,flags);
+	spin_lock_irqsave(&db->lock, flags);
 	reg_save = readb(db->io_addr);
 
 	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer read command */
@@ -307,7 +306,7 @@ dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 
 	/* restore the previous address */
 	writeb(reg_save, db->io_addr);
-	spin_unlock_irqrestore(&db->lock,flags);
+	spin_unlock_irqrestore(&db->lock, flags);
 
 	mutex_unlock(&db->addr_lock);
 
@@ -315,9 +314,7 @@ dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 	return ret;
 }
 
-/*
- *   Write a word to phyxcer
- */
+/* Write a word to phyxcer */
 static void
 dm9000_phy_write(struct net_device *dev,
 		 int phyaddr_unused, int reg, int value)
@@ -329,7 +326,7 @@ dm9000_phy_write(struct net_device *dev,
 	dm9000_dbg(db, 5, "phy_write[%02x] = %04x\n", reg, value);
 	mutex_lock(&db->addr_lock);
 
-	spin_lock_irqsave(&db->lock,flags);
+	spin_lock_irqsave(&db->lock, flags);
 
 	/* Save previous register address */
 	reg_save = readb(db->io_addr);
@@ -341,14 +338,15 @@ dm9000_phy_write(struct net_device *dev,
 	iow(db, DM9000_EPDRL, value);
 	iow(db, DM9000_EPDRH, value >> 8);
 
-	iow(db, DM9000_EPCR, EPCR_EPOS | EPCR_ERPRW);	/* Issue phyxcer write command */
+	/* Issue phyxcer write command */
+	iow(db, DM9000_EPCR, EPCR_EPOS | EPCR_ERPRW);
 
 	writeb(reg_save, db->io_addr);
 	spin_unlock_irqrestore(&db->lock, flags);
 
 	dm9000_msleep(db, 1);		/* Wait write complete */
 
-	spin_lock_irqsave(&db->lock,flags);
+	spin_lock_irqsave(&db->lock, flags);
 	reg_save = readb(db->io_addr);
 
 	iow(db, DM9000_EPCR, 0x0);	/* Clear phyxcer write command */
-- 
1.7.1
