From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH] pasemi_mac: ethtool set settings support
Date: Mon, 5 Oct 2009 17:31:24 +0400
Message-ID: <20091005133124.GA11717@ru.mvista.com>
References: <4AC9ED9B.5040400@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jgarzik@pobox.com, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <4AC9ED9B.5040400@ru.mvista.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Add ethtool set settings to pasemi_mac_ethtool.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
---
 drivers/net/pasemi_mac_ethtool.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff -pruN linux-2.6.orig/drivers/net/pasemi_mac_ethtool.c linux-2.6/drivers/net/pasemi_mac_ethtool.c
--- linux-2.6.orig/drivers/net/pasemi_mac_ethtool.c	2009-10-05 16:24:14.000000000 +0400
+++ linux-2.6./drivers/net/pasemi_mac_ethtool.c	2009-10-05 16:27:08.000000000 +0400
@@ -77,6 +77,19 @@ pasemi_mac_ethtool_get_settings(struct n
 	return phy_ethtool_gset(phydev, cmd);
 }
 
+static int
+pasemi_mac_ethtool_set_settings(struct net_device *netdev,
+			       struct ethtool_cmd *cmd)
+{
+	struct pasemi_mac *mac = netdev_priv(netdev);
+	struct phy_device *phydev = mac->phydev;
+
+	if (!phydev)
+		return -EOPNOTSUPP;
+
+	return phy_ethtool_sset(phydev, cmd);
+}
+
 static void
 pasemi_mac_ethtool_get_drvinfo(struct net_device *netdev,
 			       struct ethtool_drvinfo *drvinfo)
@@ -150,6 +163,7 @@ static void pasemi_mac_get_strings(struc
 
 const struct ethtool_ops pasemi_mac_ethtool_ops = {
 	.get_settings		= pasemi_mac_ethtool_get_settings,
+	.set_settings		= pasemi_mac_ethtool_set_settings,
 	.get_drvinfo		= pasemi_mac_ethtool_get_drvinfo,
 	.get_msglevel		= pasemi_mac_ethtool_get_msglevel,
 	.set_msglevel		= pasemi_mac_ethtool_set_msglevel,
