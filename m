From: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
Subject: [PATCH] net: phy: turn carrier off on phy attach
Date: Thu, 14 Jan 2016 21:57:18 +0100
Message-ID: <1452805038-27178-1-git-send-email-sjoerd.simons@collabora.co.uk>
Cc: Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:42790 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbcANU5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 15:57:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index 0bfbaba..0b407dd 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -668,6 +668,11 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 	phydev->state = PHY_READY;
 
+	/* Initial carrier state is off as the phy is about to be
+	 * (re)initialized.
+	 */
+	netif_carrier_off(phydev->attached_dev);
+
 	/* Do initial configuration here, now that
 	 * we have certain key parameters
 	 * (dev_flags and interface)
-- 
2.7.0.rc3
