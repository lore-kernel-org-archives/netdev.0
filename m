From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH] net: phy: fix uninitalized WOL parameters in phy_ethtool_get_wol
Date: Mon, 10 Mar 2014 02:01:10 +0100
Message-ID: <1394413270-7169-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

phy_ethtool_get_wol is a helper to get current WOL settings from
a phy device. When using this helper on a PHY without .get_wol
callback, struct ethtool_wolinfo is never set-up correctly and
may contain misleading information about WOL status.

To fix this, always zero relevant fields of struct ethtool_wolinfo
regardless of .get_wol callback availability.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David Miller <davem@davemloft.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/phy/phy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 19c9eca0ef26..62a7cd401e1c 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1092,6 +1092,7 @@ EXPORT_SYMBOL(phy_ethtool_set_wol);
 
 void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
 {
+	wol->supported = wol->wolopts = 0;
 	if (phydev->drv->get_wol)
 		phydev->drv->get_wol(phydev, wol);
 }
-- 
1.8.5.3
