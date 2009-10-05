From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH] pasemi_mac: ethtool get settings fix
Date: Mon, 5 Oct 2009 17:27:56 +0400
Message-ID: <20091005132756.GA11704@ru.mvista.com>
References: <4AC9ED9B.5040400@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jgarzik@pobox.com, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <4AC9ED9B.5040400@ru.mvista.com>
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
 drivers/net/pasemi_mac_ethtool.c |    3 +++
 1 file changed, 3 insertions(+)

diff -pruN linux-2.6.orig/drivers/net/pasemi_mac_ethtool.c linux-2.6/drivers/net/pasemi_mac_ethtool.c
--- linux-2.6.orig/drivers/net/pasemi_mac_ethtool.c	2009-02-14 03:23:08.000000000 +0300
+++ linux-2.6/drivers/net/pasemi_mac_ethtool.c	2009-10-05 16:21:52.000000000 +0400
@@ -71,6 +71,9 @@ pasemi_mac_ethtool_get_settings(struct n
 	struct pasemi_mac *mac = netdev_priv(netdev);
 	struct phy_device *phydev = mac->phydev;
 
+	if (!phydev)
+		return -EOPNOTSUPP;
+
 	return phy_ethtool_gset(phydev, cmd);
 }
