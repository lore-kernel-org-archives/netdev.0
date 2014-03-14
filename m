From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH] net: phy: fix uninitalized ethtool_wolinfo in phy_suspend
Date: Fri, 14 Mar 2014 10:07:44 +0100
Message-ID: <1394788064-6832-1-git-send-email-sebastian.hesselbarth@gmail.com>
References: <20140313.153832.967564223480298567.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140313.153832.967564223480298567.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Callers of phy_ethtool_get_wol are supposed to provide a properly
cleared struct ethtool_wolinfo. Therefore, fix phy_suspend to clear
it before passing it to phy_ethtool_get_wol.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David Miller <davem@davemloft.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/phy/phy_device.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 4b03e63639b7..7512e28866f1 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -683,10 +683,9 @@ EXPORT_SYMBOL(phy_detach);
 int phy_suspend(struct phy_device *phydev)
 {
 	struct phy_driver *phydrv = to_phy_driver(phydev->dev.driver);
-	struct ethtool_wolinfo wol;
+	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
 
 	/* If the device has WOL enabled, we cannot suspend the PHY */
-	wol.cmd = ETHTOOL_GWOL;
 	phy_ethtool_get_wol(phydev, &wol);
 	if (wol.wolopts)
 		return -EBUSY;
-- 
1.8.5.3
