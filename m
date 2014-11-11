From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 08/22] net: phy: micrel: disable broadcast for KSZ8081/KSZ8091
Date: Tue, 11 Nov 2014 18:37:26 +0100
Message-ID: <1415727460-20417-9-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Disable PHY address 0 as the broadcast address, so that it can be used
as a unique (non-broadcast) address on a shared bus.

Note that this can also be configured using the B-CAST_OFF pin on
KSZ9091, but that KSZ8081 lacks this pin and is also limited to
addresses 0 and 3.

Specifically, this allows for dual KSZ8081 setups.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 21abe5ade3df..16135ac18bfe 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -243,6 +243,13 @@ static int ks8051_config_init(struct phy_device *phydev)
 	return rc < 0 ? rc : 0;
 }
 
+static int ksz8081_config_init(struct phy_device *phydev)
+{
+	kszphy_broadcast_disable(phydev);
+
+	return 0;
+}
+
 static int ksz9021_load_values_from_of(struct phy_device *phydev,
 				       struct device_node *of_node, u16 reg,
 				       char *field1, char *field2,
@@ -605,7 +612,7 @@ static struct phy_driver ksphy_driver[] = {
 	.phy_id_mask	= 0x00fffff0,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
+	.config_init	= ksz8081_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-- 
2.0.4
