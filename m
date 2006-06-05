From: Nathaniel Case <ncase@xes-inc.com>
Subject: [PATCH 2/2] PHYLIB/gianfar: Use phy_ethtool_get_link() for
	get_link op
Date: Mon, 05 Jun 2006 18:48:54 -0500
Message-ID: <1149551334.10700.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:7343 "EHLO xes-mad.com")
	by vger.kernel.org with ESMTP id S1750913AbWFEXs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 19:48:56 -0400
To: Andy Fleming <afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the gianfar ethtool code use phy_ethtool_get_link() instead of
ethtool_op_get_link().

Patch depends on previous one (1/2).

Signed-off-by: Nate Case <ncase@xes-inc.com>

---

--- a/drivers/net/gianfar_ethtool.c	2006-06-05 11:27:19.000000000 -0500
+++ b/drivers/net/gianfar_ethtool.c	2006-06-04 19:31:01.000000000 -0500
@@ -228,6 +228,18 @@
 		buf[i] = gfar_read(&theregs[i]);
 }
 
+static u32 gfar_get_link(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+
+	if (NULL == phydev)
+		return -ENODEV;
+
+	return phy_ethtool_get_link(phydev);
+}
+
+
 /* Convert microseconds to ethernet clock ticks, which changes
  * depending on what speed the controller is running at */
 static unsigned int gfar_usecs2ticks(struct gfar_private *priv, unsigned int usecs)
@@ -574,7 +578,7 @@
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
 	.get_regs = gfar_get_regs,
-	.get_link = ethtool_op_get_link,
+	.get_link = gfar_get_link,
 	.get_coalesce = gfar_gcoalesce,
 	.set_coalesce = gfar_scoalesce,
 	.get_ringparam = gfar_gringparam,


