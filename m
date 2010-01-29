From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/13] tulip/eeprom.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:21 -0800
Message-ID: <0be4ec80ea34cafbe4583cd13aa5c537e799e32a.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1587 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009Ab0A2G7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:31 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/eeprom.c |   47 ++++++++++++++++++++++---------------------
 1 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/tulip/eeprom.c
index 889f57a..93f4e83 100644
--- a/drivers/net/tulip/eeprom.c
+++ b/drivers/net/tulip/eeprom.c
@@ -161,15 +161,15 @@ void __devinit tulip_parse_eeprom(struct net_device *dev)
 		if (ee_data[0] == 0xff) {
 			if (last_mediatable) {
 				controller_index++;
-				printk(KERN_INFO "%s:  Controller %d of multiport board.\n",
-					   dev->name, controller_index);
+				dev_info(&dev->dev,
+					 "Controller %d of multiport board\n",
+					 controller_index);
 				tp->mtable = last_mediatable;
 				ee_data = last_ee_data;
 				goto subsequent_board;
 			} else
-				printk(KERN_INFO "%s:  Missing EEPROM, this interface may "
-					   "not work correctly!\n",
-			   dev->name);
+				dev_info(&dev->dev,
+					 "Missing EEPROM, this interface may not work correctly!\n");
 			return;
 		}
 	  /* Do a fix-up based on the vendor half of the station address prefix. */
@@ -181,16 +181,15 @@ void __devinit tulip_parse_eeprom(struct net_device *dev)
 			  i++;			/* An Accton EN1207, not an outlaw Maxtech. */
 		  memcpy(ee_data + 26, eeprom_fixups[i].newtable,
 				 sizeof(eeprom_fixups[i].newtable));
-		  printk(KERN_INFO "%s: Old format EEPROM on '%s' board.  Using"
-				 " substitute media control info.\n",
-				 dev->name, eeprom_fixups[i].name);
+		  dev_info(&dev->dev,
+			   "Old format EEPROM on '%s' board.  Using substitute media control info\n",
+			   eeprom_fixups[i].name);
 		  break;
 		}
 	  }
 	  if (eeprom_fixups[i].name == NULL) { /* No fixup found. */
-		  printk(KERN_INFO "%s: Old style EEPROM with no media selection "
-				 "information.\n",
-			   dev->name);
+		  dev_info(&dev->dev,
+			   "Old style EEPROM with no media selection information\n");
 		return;
 	  }
 	}
@@ -218,7 +217,8 @@ subsequent_board:
 	        /* there is no phy information, don't even try to build mtable */
 	        if (count == 0) {
 			if (tulip_debug > 0)
-				printk(KERN_WARNING "%s: no phy info, aborting mtable build\n", dev->name);
+				dev_warn(&dev->dev,
+					 "no phy info, aborting mtable build\n");
 		        return;
 		}
 
@@ -234,8 +234,8 @@ subsequent_board:
 		mtable->has_nonmii = mtable->has_mii = mtable->has_reset = 0;
 		mtable->csr15dir = mtable->csr15val = 0;
 
-		printk(KERN_INFO "%s:  EEPROM default media type %s.\n", dev->name,
-			   media & 0x0800 ? "Autosense" : medianame[media & MEDIA_MASK]);
+		dev_info(&dev->dev, "EEPROM default media type %s\n",
+			 media & 0x0800 ? "Autosense" : medianame[media & MEDIA_MASK]);
 		for (i = 0; i < count; i++) {
 			struct medialeaf *leaf = &mtable->mleaf[i];
 
@@ -298,16 +298,17 @@ subsequent_board:
 			}
 			if (tulip_debug > 1  &&  leaf->media == 11) {
 				unsigned char *bp = leaf->leafdata;
-				printk(KERN_INFO "%s:  MII interface PHY %d, setup/reset "
-					   "sequences %d/%d long, capabilities %2.2x %2.2x.\n",
-					   dev->name, bp[0], bp[1], bp[2 + bp[1]*2],
-					   bp[5 + bp[2 + bp[1]*2]*2], bp[4 + bp[2 + bp[1]*2]*2]);
+				dev_info(&dev->dev,
+					 "MII interface PHY %d, setup/reset sequences %d/%d long, capabilities %02x %02x\n",
+					 bp[0], bp[1], bp[2 + bp[1]*2],
+					 bp[5 + bp[2 + bp[1]*2]*2],
+					 bp[4 + bp[2 + bp[1]*2]*2]);
 			}
-			printk(KERN_INFO "%s:  Index #%d - Media %s (#%d) described "
-				   "by a %s (%d) block.\n",
-				   dev->name, i, medianame[leaf->media & 15], leaf->media,
-				   leaf->type < ARRAY_SIZE(block_name) ? block_name[leaf->type] : "<unknown>",
-				   leaf->type);
+			dev_info(&dev->dev,
+				 "Index #%d - Media %s (#%d) described by a %s (%d) block\n",
+				 i, medianame[leaf->media & 15], leaf->media,
+				 leaf->type < ARRAY_SIZE(block_name) ? block_name[leaf->type] : "<unknown>",
+				 leaf->type);
 		}
 		if (new_advertise)
 			tp->sym_advertise = new_advertise;
-- 
1.6.6.rc0.57.gad7a

