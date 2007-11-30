From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 2/11] ibm_newemac: Add ET1011c PHY support
Date: Fri, 30 Nov 2007 16:40:24 +1100
Message-ID: <20071130054126.E3EFADDE0C@ozlabs.org>
References: <1196401223.5661.297518056501.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48281 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369AbXK3Fl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 00:41:27 -0500
In-Reply-To: <1196401223.5661.297518056501.qpush@grosgo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Roese <sr@denx.de>

This adds support for the Agere ET1011c PHY as found on the AMCC Taishan
board.

Signed-off-by: Stefan Roese <sr@denx.de>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 drivers/net/ibm_newemac/phy.c |   37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

Index: linux-work/drivers/net/ibm_newemac/phy.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/phy.c	2007-11-08 18:54:12.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/phy.c	2007-11-08 18:54:13.000000000 +1100
@@ -327,6 +327,42 @@ static int m88e1111_init(struct mii_phy 
 	return  0;
 }
 
+static int et1011c_init(struct mii_phy *phy)
+{
+        u16 reg_short;
+
+        reg_short = (u16)(phy_read(phy,0x16));
+        reg_short &= ~(0x7);
+        reg_short |= 0x6;       /* RGMII Trace Delay*/
+        phy_write(phy, 0x16, reg_short);
+
+        reg_short = (u16)(phy_read(phy, 0x17));
+        reg_short &= ~(0x40);
+        phy_write(phy, 0x17, reg_short);
+
+        phy_write(phy,0x1c,0x74f0);
+        return 0;
+}
+
+static struct mii_phy_ops et1011c_phy_ops = {
+        .init           = et1011c_init,
+        .setup_aneg     = genmii_setup_aneg,
+        .setup_forced   = genmii_setup_forced,
+        .poll_link      = genmii_poll_link,
+        .read_link      = genmii_read_link
+};
+
+static struct mii_phy_def et1011c_phy_def = {
+        .phy_id         = 0x0282f000,
+        .phy_id_mask    = 0x0fffff00,
+        .name           = "ET1011C Gigabit Ethernet",
+        .ops            = &et1011c_phy_ops
+};
+
+
+
+
+
 static struct mii_phy_ops m88e1111_phy_ops = {
 	.init		= m88e1111_init,
 	.setup_aneg	= genmii_setup_aneg,
@@ -344,6 +380,7 @@ static struct mii_phy_def m88e1111_phy_d
 };
 
 static struct mii_phy_def *mii_phy_table[] = {
+	&et1011c_phy_def,
 	&cis8201_phy_def,
 	&bcm5248_phy_def,
 	&m88e1111_phy_def,
