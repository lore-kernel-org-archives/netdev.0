From: Ron Madrid <ron_madrid@sbcglobal.net>
Subject: [PATCH] Marvell 88E1118 interrupt fix
Date: Fri, 23 Jan 2009 12:04:10 -0800
Message-ID: <1232741050-6960-1-git-send-email-ron_madrid@sbcglobal.net>
Cc: Ron Madrid <ron_madrid@sbcglobal.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp125.sbc.mail.sp1.yahoo.com ([69.147.65.184]:22579 "HELO
	smtp125.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753608AbZAWUDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 15:03:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adjusts the LED control so that interrupt lines are not reading LEDs
and effectively causing indefinite interrupts to the controller.

Signed-off-by: Ron Madrid <ron_madrid@sbcglobal.net>
---
 drivers/net/tsec.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tsec.c b/drivers/net/tsec.c
index d7da081..c9aa29d 100644
--- a/drivers/net/tsec.c
+++ b/drivers/net/tsec.c
@@ -1141,6 +1141,9 @@ struct phy_info phy_info_M88E1118 = {
 		{MIIM_CONTROL, MIIM_CONTROL_RESET, NULL},
 		{0x16, 0x0002, NULL}, /* Change Page Number */
 		{0x15, 0x1070, NULL}, /* Delay RGMII TX and RX */
+		{0x16, 0x0003, NULL}, /* Change Page Number */
+		{0x10, 0x021e, NULL}, /* Adjust LED control */
+		{0x16, 0x0000, NULL}, /* Change Page Number */
 		{MIIM_GBIT_CONTROL, MIIM_GBIT_CONTROL_INIT, NULL},
 		{MIIM_ANAR, MIIM_ANAR_INIT, NULL},
 		{MIIM_CONTROL, MIIM_CONTROL_RESET, NULL},
@@ -1152,6 +1155,7 @@ struct phy_info phy_info_M88E1118 = {
 		/* Status is read once to clear old link state */
 		{MIIM_STATUS, miim_read, NULL},
 		/* Auto-negotiate */
+		{MIIM_STATUS, miim_read, &mii_parse_sr},
 		/* Read the status */
 		{MIIM_88E1011_PHY_STATUS, miim_read,
 		 &mii_parse_88E1011_psr},
-- 
1.5.5.1

