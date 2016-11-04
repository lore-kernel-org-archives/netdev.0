From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH 2/2] net: ethernet: nb8800: handle all RGMII declinations
Date: Fri, 4 Nov 2016 16:05:52 +0100
Message-ID: <581CA3D0.6080808@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit a999589ccaae ("phylib: add RGMII-ID interface mode definition")
and commit 7d400a4c5897 ("phylib: add PHY interface modes for internal
delay for tx and rx only") added several RGMII declinations:
PHY_INTERFACE_MODE_RGMII_ID, PHY_INTERFACE_MODE_RGMII_RXID and
PHY_INTERFACE_MODE_RGMII_TXID to deal with internal delays.

Those are all RGMII modes (1Gbit) and must be considered that way when
setting the MAC Mode or the Pads Mode for the HW to work properly.

Signed-off-by: Sebastian Frias <sf84@laposte.net>
---
 drivers/net/ethernet/aurora/nb8800.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index d2855c9..6230ace 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -609,7 +609,10 @@ static void nb8800_mac_config(struct net_device *dev)
 		mac_mode |= HALF_DUPLEX;
 
 	if (gigabit) {
-		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII)
+		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII ||
+		    priv->phy_mode == PHY_INTERFACE_MODE_RGMII_ID ||
+		    priv->phy_mode == PHY_INTERFACE_MODE_RGMII_RXID ||
+		    priv->phy_mode == PHY_INTERFACE_MODE_RGMII_TXID)
 			mac_mode |= RGMII_MODE;
 
 		mac_mode |= GMAC_MODE;
@@ -1278,9 +1281,8 @@ static int nb8800_tangox_init(struct net_device *dev)
 		break;
 
 	case PHY_INTERFACE_MODE_RGMII:
-		pad_mode = PAD_MODE_RGMII;
-		break;
-
+	case PHY_INTERFACE_MODE_RGMII_ID:
+	case PHY_INTERFACE_MODE_RGMII_RXID:
 	case PHY_INTERFACE_MODE_RGMII_TXID:
 		pad_mode = PAD_MODE_RGMII;
 		break;
-- 
1.7.11.2
