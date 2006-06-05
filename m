From: Nathaniel Case <ncase@xes-inc.com>
Subject: [PATCH 1/2] PHYLIB: Add get_link ethtool helper function
Date: Mon, 05 Jun 2006 18:48:12 -0500
Message-ID: <1149551292.10700.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:4015 "EHLO xes-mad.com")
	by vger.kernel.org with ESMTP id S1750809AbWFEXsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 19:48:15 -0400
To: Andy Fleming <afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a phy_ethtool_get_link() function along the same lines as
phy_ethtool_gset().  This provides drivers utilizing PHYLIB an
alternative to using ethtool_op_get_link().  This is more desirable
since the "Link detected" field in ethtool would actually reflect the
state of the PHY register.

Patch depends on previous patch (0/2).

Signed-off-by: Nate Case <ncase@xes-inc.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>

---

--- a/drivers/net/phy/phy.c	2006-06-04 16:01:59.000000000 -0500
+++ b/drivers/net/phy/phy.c	2006-06-05 10:55:31.000000000 -0500
@@ -301,6 +301,22 @@
 	return 0;
 }
 
+/* 
+ * phy_ethtool_get_link:
+ * A generic ethtool get_link function which is more accurate than
+ * the network interface carrier status since it queries the
+ * PHY directly.
+ */
+u32 phy_ethtool_get_link(struct phy_device *phydev)
+{
+	int err;
+
+	err = genphy_update_link(phydev);
+	if (err)
+		return 0;
+
+	return (u32) phydev->link;
+}
 
 /* Note that this function is currently incompatible with the
  * PHYCONTROL layer.  It changes registers without regard to
--- a/include/linux/phy.h	2006-06-05 11:33:59.000000000 -0500
+++ b/include/linux/phy.h	2006-06-04 19:31:51.000000000 -0500
@@ -374,6 +374,7 @@
 void phy_stop_machine(struct phy_device *phydev);
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
+u32 phy_ethtool_get_link(struct phy_device *phydev);
 int phy_mii_ioctl(struct phy_device *phydev,
 		struct mii_ioctl_data *mii_data, int cmd);
 int phy_start_interrupts(struct phy_device *phydev);



