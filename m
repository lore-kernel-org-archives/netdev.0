From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 1/5] eeprom_93cx6: Add data direction control.
Date: Mon, 21 Nov 2011 10:57:56 -0800
Message-ID: <1321901880-12883-2-git-send-email-sboyd@codeaurora.org>
References: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Cc: Ben Dooks <ben@simtec.co.uk>, linux-kernel@vger.kernel.org,
	Sebastien Jan <s-jan@ti.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Jean Delvare <khali@linux-fr.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:18939 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673Ab1KUS6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 13:58:04 -0500
In-Reply-To: <1321901880-12883-1-git-send-email-sboyd@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben@simtec.co.uk>

Some devices need to know if the data is to be output or read, so add a
data direction into the eeprom structure to tell the driver whether the
data line should be driven.

The user in this case is the Micrel KS8851 which has a direction
control for the EEPROM data line and thus needs to know whether
to drive it (writing) or to tristate it for receiving.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>
Cc: Wolfram Sang <w.sang@pengutronix.de>
Cc: Jean Delvare <khali@linux-fr.org>
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 drivers/misc/eeprom/eeprom_93cx6.c |    3 +++
 include/linux/eeprom_93cx6.h       |    2 ++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/misc/eeprom/eeprom_93cx6.c b/drivers/misc/eeprom/eeprom_93cx6.c
index 7b33de9..a6037af 100644
--- a/drivers/misc/eeprom/eeprom_93cx6.c
+++ b/drivers/misc/eeprom/eeprom_93cx6.c
@@ -63,6 +63,7 @@ static void eeprom_93cx6_startup(struct eeprom_93cx6 *eeprom)
 	eeprom->reg_data_out = 0;
 	eeprom->reg_data_clock = 0;
 	eeprom->reg_chip_select = 1;
+	eeprom->drive_data = 1;
 	eeprom->register_write(eeprom);
 
 	/*
@@ -101,6 +102,7 @@ static void eeprom_93cx6_write_bits(struct eeprom_93cx6 *eeprom,
 	 */
 	eeprom->reg_data_in = 0;
 	eeprom->reg_data_out = 0;
+	eeprom->drive_data = 1;
 
 	/*
 	 * Start writing all bits.
@@ -140,6 +142,7 @@ static void eeprom_93cx6_read_bits(struct eeprom_93cx6 *eeprom,
 	 */
 	eeprom->reg_data_in = 0;
 	eeprom->reg_data_out = 0;
+	eeprom->drive_data = 0;
 
 	/*
 	 * Start reading all bits.
diff --git a/include/linux/eeprom_93cx6.h b/include/linux/eeprom_93cx6.h
index c4627cb..e04546e 100644
--- a/include/linux/eeprom_93cx6.h
+++ b/include/linux/eeprom_93cx6.h
@@ -46,6 +46,7 @@
  * @register_write(struct eeprom_93cx6 *eeprom): handler to
  * write to the eeprom register by using all reg_* fields.
  * @width: eeprom width, should be one of the PCI_EEPROM_WIDTH_* defines
+ * @drive_data: Set if we're driving the data line.
  * @reg_data_in: register field to indicate data input
  * @reg_data_out: register field to indicate data output
  * @reg_data_clock: register field to set the data clock
@@ -62,6 +63,7 @@ struct eeprom_93cx6 {
 
 	int width;
 
+	char drive_data;
 	char reg_data_in;
 	char reg_data_out;
 	char reg_data_clock;
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
