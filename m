From: Barry Song <21cnbao@gmail.com>
Subject: [PATCH] dm9000: fix a lot of checkpatch issues
Date: Wed, 15 Jan 2014 23:31:46 +0800
Message-ID: <1389799906-2260-1-git-send-email-21cnbao@gmail.com>
Cc: netdev@vger.kernel.org, workgroup.linux@csr.com,
	Barry Song <Baohua.Song@csr.com>
To: davem@davemloft.net, nikita@compulab.co.il,
	grinberg@compulab.co.il, jg1.han@samsung.com, mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:58847 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaAOPcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 10:32:20 -0500
Received: by mail-pa0-f53.google.com with SMTP id lj1so1273816pab.26
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 07:32:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Song <Baohua.Song@csr.com>

recently, dm9000 codes have many checkpatch errors and warnings:

WARNING: please, no space before tabs
3: FILE: dm9000.c:3:
+ * ^ICopyright (C) 1997  Sten Wang$

WARNING: please, no space before tabs
5: FILE: dm9000.c:5:
+ * ^IThis program is free software; you can redistribute it and/or$

WARNING: please, no space before tabs
6: FILE: dm9000.c:6:
+ * ^Imodify it under the terms of the GNU General Public License$

WARNING: please, no space before tabs
7: FILE: dm9000.c:7:
+ * ^Ias published by the Free Software Foundation; either version 2$

WARNING: please, no space before tabs
8: FILE: dm9000.c:8:
+ * ^Iof the License, or (at your option) any later version.$

WARNING: please, no space before tabs
10: FILE: dm9000.c:10:
+ * ^IThis program is distributed in the hope that it will be useful,$

WARNING: please, no space before tabs
11: FILE: dm9000.c:11:
+ * ^Ibut WITHOUT ANY WARRANTY; without even the implied warranty of$

WARNING: please, no space before tabs
12: FILE: dm9000.c:12:
+ * ^IMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the$

WARNING: please, no space before tabs
13: FILE: dm9000.c:13:
+ * ^IGNU General Public License for more details.$

WARNING: do not add new typedefs
97: FILE: dm9000.c:97:
+typedef struct board_info {

ERROR: spaces prohibited around that ':' (ctx:WxV)
113: FILE: dm9000.c:113:
+	unsigned int	in_suspend :1;
 	            	           ^

ERROR: spaces prohibited around that ':' (ctx:WxV)
114: FILE: dm9000.c:114:
+	unsigned int	wake_supported :1;
 	            	               ^

This patch fixes important errors in it.

Signed-off-by: Barry Song <Baohua.Song@csr.com>
---
 drivers/net/ethernet/davicom/dm9000.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 7080ad6..878b748 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -110,8 +110,8 @@ typedef struct board_info {
 	u8		imr_all;
 
 	unsigned int	flags;
-	unsigned int	in_suspend :1;
-	unsigned int	wake_supported :1;
+	unsigned int	in_suspend:1;
+	unsigned int	wake_supported:1;
 
 	enum dm9000_type type;
 
@@ -162,7 +162,7 @@ static inline board_info_t *to_dm9000_board(struct net_device *dev)
  *   Read a byte from I/O port
  */
 static u8
-ior(board_info_t * db, int reg)
+ior(board_info_t *db, int reg)
 {
 	writeb(reg, db->io_addr);
 	return readb(db->io_data);
@@ -173,7 +173,7 @@ ior(board_info_t * db, int reg)
  */
 
 static void
-iow(board_info_t * db, int reg, int value)
+iow(board_info_t *db, int reg, int value)
 {
 	writeb(reg, db->io_addr);
 	writeb(value, db->io_data);
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
@@ -1252,12 +1252,11 @@ static irqreturn_t dm9000_wol_interrupt(int irq, void *dev_id)
 			dev_info(db->dev, "wake by link status change\n");
 		if (wcr & WCR_SAMPLEST)
 			dev_info(db->dev, "wake by sample packet\n");
-		if (wcr & WCR_MAGICST )
+		if (wcr & WCR_MAGICST)
 			dev_info(db->dev, "wake by magic packet\n");
 		if (!(wcr & (WCR_LINKST | WCR_SAMPLEST | WCR_MAGICST)))
 			dev_err(db->dev, "wake signalled with no reason? "
 				"NSR=0x%02x, WSR=0x%02x\n", nsr, wcr);
-
 	}
 
 	spin_unlock_irqrestore(&db->lock, flags);
@@ -1314,7 +1313,7 @@ dm9000_open(struct net_device *dev)
 
 	mii_check_media(&db->mii, netif_msg_link(db), 1);
 	netif_start_queue(dev);
-	
+
 	dm9000_schedule_poll(db);
 
 	return 0;
@@ -1628,7 +1627,7 @@ dm9000_probe(struct platform_device *pdev)
 
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
 		/* try reading from mac */
-		
+
 		mac_src = "chip";
 		for (i = 0; i < 6; i++)
 			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
-- 
1.7.5.4
