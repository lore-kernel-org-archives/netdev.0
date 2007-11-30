From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 1/11] ibm_newemac: Add BCM5248 and Marvell 88E1111 PHY support
Date: Fri, 30 Nov 2007 16:40:23 +1100
Message-ID: <20071130054126.39BDCDDE0A@ozlabs.org>
References: <1196401223.5661.297518056501.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48277 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751384AbXK3Fl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 00:41:27 -0500
In-Reply-To: <1196401223.5661.297518056501.qpush@grosgo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Roese <sr@denx.de>

This patch adds BCM5248 and Marvell 88E1111 PHY support to NEW EMAC driver.
These PHY chips are used on PowerPC 440EPx boards.
The PHY code is based on the previous work by Stefan Roese <sr@denx.de>

Signed-off-by: Stefan Roese <sr@denx.de>
Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

--- linux.orig/drivers/net/ibm_newemac/phy.c	2007-06-15 21:45:18.000000000 +0400
+++ linux/drivers/net/ibm_newemac/phy.c	2007-06-15 20:45:15.000000000 +0400
@@ -306,8 +306,47 @@
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
+	printk("%s: Marvell 88E1111 Ethernet\n", __FUNCTION__);
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
_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
