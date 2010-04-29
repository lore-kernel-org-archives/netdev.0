From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 03/13] eeprom_93cx6: Add data direction control.
Date: Fri, 30 Apr 2010 00:16:24 +0100
Message-ID: <20100429231739.749602911@fluff.org.uk>
References: <20100429231621.015936077@fluff.org.uk>
Cc: tristram.ha@micrel.com, support@tincantools.com,
	Wolfram Sang <w.sang@pengutronix.de>,
	Jean Delvare <khali@linux-fr.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=93c-eeprom-add-direction.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some devices need to know if the data is to be output or read, so add a
data direction into the eeprom structure to tell the driver whether the
data line should be driven.

The user in this case is the Micrel KS8851 which has a direction
control for the EEPROM data line and thus needs to know whether
to drive it (writing) or to tristate it for receiving.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>
Cc: Wolfram Sang <w.sang@pengutronix.de>
Cc: Jean Delvare <khali@linux-fr.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

--
 drivers/misc/eeprom/eeprom_93cx6.c |    3 +++
 include/linux/eeprom_93cx6.h       |    2 ++
 2 files changed, 5 insertions(+)

Index: b/drivers/misc/eeprom/eeprom_93cx6.c
===================================================================
--- a/drivers/misc/eeprom/eeprom_93cx6.c	2009-10-06 15:35:38.000000000 +0100
+++ b/drivers/misc/eeprom/eeprom_93cx6.c	2009-10-06 15:51:18.000000000 +0100
@@ -70,6 +70,7 @@ static void eeprom_93cx6_startup(struct 
 	eeprom->reg_data_out = 0;
 	eeprom->reg_data_clock = 0;
 	eeprom->reg_chip_select = 1;
+	eeprom->drive_data = 1;
 	eeprom->register_write(eeprom);
 
 	/*
@@ -108,6 +109,7 @@ static void eeprom_93cx6_write_bits(stru
 	 */
 	eeprom->reg_data_in = 0;
 	eeprom->reg_data_out = 0;
+	eeprom->drive_data = 1;
 
 	/*
 	 * Start writing all bits.
@@ -147,6 +149,7 @@ static void eeprom_93cx6_read_bits(struc
 	 */
 	eeprom->reg_data_in = 0;
 	eeprom->reg_data_out = 0;
+	eeprom->drive_data = 0;
 
 	/*
 	 * Start reading all bits.
Index: b/include/linux/eeprom_93cx6.h
===================================================================
--- a/include/linux/eeprom_93cx6.h	2009-10-06 15:35:38.000000000 +0100
+++ b/include/linux/eeprom_93cx6.h	2009-10-06 15:51:18.000000000 +0100
@@ -45,6 +45,7 @@
  * @register_write(struct eeprom_93cx6 *eeprom): handler to
  * write to the eeprom register by using all reg_* fields.
  * @width: eeprom width, should be one of the PCI_EEPROM_WIDTH_* defines
+ * @drive_data: Set if we're driving the data line.
  * @reg_data_in: register field to indicate data input
  * @reg_data_out: register field to indicate data output
  * @reg_data_clock: register field to set the data clock
@@ -61,6 +62,7 @@ struct eeprom_93cx6 {
 
 	int width;
 
+	char drive_data;
 	char reg_data_in;
 	char reg_data_out;
 	char reg_data_clock;
