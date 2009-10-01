From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH] pasemi_mac: ethtool get settings fix
Date: Fri, 2 Oct 2009 02:27:48 +0400
Message-ID: <20091001222748.GA21276@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Not all pasemi mac interfaces can have a phy attached.
For example, XAUI has no phy and phydev is NULL for it.
In this case ethtool get settings causes kernel crash.
Fix it by returning -EOPNOTSUPP if there's no PHY attached.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
---
 drivers/net/pasemi_mac_ethtool.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux-2.6.21.orig/drivers/net/pasemi_mac_ethtool.c	2008-11-06 18:10:38.000000000 +0300
+++ linux-2.6.21/drivers/net/pasemi_mac_ethtool.c	2008-11-19 19:24:28.000000000 +0300
@@ -71,6 +71,8 @@ pasemi_mac_ethtool_get_settings(struct n
 	struct pasemi_mac *mac = netdev_priv(netdev);
 	struct phy_device *phydev = mac->phydev;
 
+	if (!phydev)
+		return -EOPNOTSUPP;
 	return phy_ethtool_gset(phydev, cmd);
 }
