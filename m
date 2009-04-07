From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH 3/3] phylib: Add interrupt source check function to M88E1121R driver
Date: Tue,  7 Apr 2009 14:01:43 +0200
Message-ID: <1239105703-26240-3-git-send-email-agust@denx.de>
References: <1239105703-26240-1-git-send-email-agust@denx.de>
 <1239105703-26240-2-git-send-email-agust@denx.de>
Cc: afleming@freescale.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:47917 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755775AbZDGMBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 08:01:50 -0400
In-Reply-To: <1239105703-26240-2-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add did_interrupt() function to check if a PHY port
really caused an interrupt. This is needed in the case
of shared PHY interrupt pin configuration to stop
interrupt event processing for PHY ports which didn't
cause an interrupt.

Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
 drivers/net/phy/marvell.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e9f436b..7a3ec9d 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -458,6 +458,18 @@ static int marvell_read_status(struct phy_device *phydev)
 	return 0;
 }
 
+static int m88e1121_did_interrupt(struct phy_device *phydev)
+{
+	int imask;
+
+	imask = phy_read(phydev, MII_M1011_IEVENT);
+
+	if (imask & MII_M1011_IMASK_INIT)
+		return 1;
+
+	return 0;
+}
+
 static struct phy_driver marvell_drivers[] = {
 	{
 		.phy_id = 0x01410c60,
@@ -520,6 +532,7 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
+		.did_interrupt = &m88e1121_did_interrupt,
 		.driver = { .owner = THIS_MODULE },
 	},
 	{
-- 
1.5.6.3

