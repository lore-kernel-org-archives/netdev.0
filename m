From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 1/11] ibm_newemac: Add BCM5248 and Marvell 88E1111 PHY support
Date: Wed, 05 Dec 2007 11:14:25 +1100
Message-ID: <20071205001534.D681ADDF2D@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51332 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081AbXLEAPf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 19:15:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>

This patch adds BCM5248 and Marvell 88E1111 PHY support to NEW EMAC driver.
These PHY chips are used on PowerPC 440EPx boards.
The PHY code is based on the previous work by Stefan Roese <sr@denx.de>

Signed-off-by: Stefan Roese <sr@denx.de>
Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 drivers/net/ibm_newemac/phy.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

Index: linux-work/drivers/net/ibm_newemac/phy.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/phy.c	2007-12-03 11:50:26.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/phy.c	2007-12-03 11:58:16.000000000 +1100
@@ -306,8 +306,47 @@ static struct mii_phy_def cis8201_phy_de
 	.ops		= &cis8201_phy_ops
 };
 
+static struct mii_phy_def bcm5248_phy_def = {
+
+	.phy_id		= 0x0143bc00,
+	.phy_id_mask	= 0x0ffffff0,
+	.name		= "BCM5248 10/100 SMII Ethernet",
+	.ops		= &generic_phy_ops
+};
+
+static int m88e1111_init(struct mii_phy *phy)
+{
+	pr_debug("%s: Marvell 88E1111 Ethernet\n", __FUNCTION__);
+	phy_write(phy, 0x14, 0x0ce3);
+	phy_write(phy, 0x18, 0x4101);
+	phy_write(phy, 0x09, 0x0e00);
+	phy_write(phy, 0x04, 0x01e1);
+	phy_write(phy, 0x00, 0x9140);
+	phy_write(phy, 0x00, 0x1140);
+
+	return  0;
+}
+
+static struct mii_phy_ops m88e1111_phy_ops = {
+	.init		= m88e1111_init,
+	.setup_aneg	= genmii_setup_aneg,
+	.setup_forced	= genmii_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= genmii_read_link
+};
+
+static struct mii_phy_def m88e1111_phy_def = {
+
+	.phy_id		= 0x01410CC0,
+	.phy_id_mask	= 0x0ffffff0,
+	.name		= "Marvell 88E1111 Ethernet",
+	.ops		= &m88e1111_phy_ops,
+};
+
 static struct mii_phy_def *mii_phy_table[] = {
 	&cis8201_phy_def,
+	&bcm5248_phy_def,
+	&m88e1111_phy_def,
 	&genmii_phy_def,
 	NULL
 };
