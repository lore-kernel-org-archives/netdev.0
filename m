From: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
Subject: [PATCH] net: phy: turn carrier off on phy attach
Date: Sat,  9 Jan 2016 19:44:05 +0100
Message-ID: <1452365045-5364-1-git-send-email-sjoerd.simons@collabora.co.uk>
Cc: linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The operstate of a networking device initially IF_OPER_UNKNOWN aka
"unknown", updated on carrier state changes (with carrier state being on
by default). This means it will stay unknown unless the carrier state
goes to off at some point, which is not the case if the phy is already
up/connected at startup.

Explicitly turn off the carrier on phy attach, leaving the phy state
machine to turn the carrier on when it has done the initial negotiation.

Signed-off-by: Sjoerd Simons <sjoerd.simons@collabora.co.uk>

---

 drivers/net/phy/phy_device.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 0bfbaba..a30ce1a 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -668,6 +668,11 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 	phydev->state = PHY_READY;
 
+	/* Signal to the core network layer the phy supports
+	 *  carrier detection
+	 */
+	netif_carrier_off(phydev->attached_dev);
+
 	/* Do initial configuration here, now that
 	 * we have certain key parameters
 	 * (dev_flags and interface)
-- 
2.7.0.rc3
