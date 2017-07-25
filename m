From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH v3] net: ethernet: nb8800: Handle all 4 RGMII modes
 identically
Date: Tue, 25 Jul 2017 14:35:03 +0200
Message-ID: <40478d08-8612-b3ab-63eb-24d12da0423f@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, Mason <slash.tmp@free.fr>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([63.128.21.107]:21722 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750861AbdGYMfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 08:35:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before commit bf8f6952a233 ("Add blurb about RGMII") it was unclear
whose responsibility it was to insert the required clock skew, and
in hindsight, some PHY drivers got it wrong. The solution forward
is to introduce a new property, explicitly requiring skew from the
node to which it is attached. In the interim, this driver will handle
all 4 RGMII modes identically (no skew).

Fixes: 52dfc8301248 ("net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller")
Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
---
 drivers/net/ethernet/aurora/nb8800.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 041cfb7952f8..e94159507847 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -609,7 +609,7 @@ static void nb8800_mac_config(struct net_device *dev)
 		mac_mode |= HALF_DUPLEX;
 
 	if (gigabit) {
-		if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII)
+		if (phy_interface_is_rgmii(dev->phydev))
 			mac_mode |= RGMII_MODE;
 
 		mac_mode |= GMAC_MODE;
@@ -1268,11 +1268,10 @@ static int nb8800_tangox_init(struct net_device *dev)
 		break;
 
 	case PHY_INTERFACE_MODE_RGMII:
-		pad_mode = PAD_MODE_RGMII;
-		break;
-
+	case PHY_INTERFACE_MODE_RGMII_ID:
+	case PHY_INTERFACE_MODE_RGMII_RXID:
 	case PHY_INTERFACE_MODE_RGMII_TXID:
-		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
+		pad_mode = PAD_MODE_RGMII;
 		break;
 
 	default:
-- 
2.11.0
