From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH v2 3/4] net: ethernet: nb8800: Fix RGMII TX clock delay setup
Date: Fri, 21 Jul 2017 13:26:30 +0200
Message-ID: <5a68bec8-0b1d-bcfe-65fb-b10399ec75be@sigmadesigns.com>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([216.205.24.107]:48934 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752433AbdGULxR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 07:53:17 -0400
In-Reply-To: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to commit e5f3a4a56ce2a707b2fb8ce37e4414dcac89c672
("Documentation: devicetree: clarify usage of the RGMII phy-modes")
there are 4 RGMII modes to handle:

"rgmii" (RX and TX delays are added by the MAC when required)
"rgmii-id" (RGMII with internal RX and TX delays provided by the PHY,
	the MAC should not add the RX or TX delays in this case)
"rgmii-rxid" (RGMII with internal RX delay provided by the PHY,
	the MAC should not add an RX delay in this case)
"rgmii-txid" (RGMII with internal TX delay provided by the PHY,
	the MAC should not add an TX delay in this case)

Add TX delay in the MAC only for rgmii and rgmii-rxid.

Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
---
 drivers/net/ethernet/aurora/nb8800.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index ded041dbafe7..f3ed320eb4ad 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1268,11 +1268,13 @@ static int nb8800_tangox_init(struct net_device *dev)
 		break;
 
 	case PHY_INTERFACE_MODE_RGMII:
-		pad_mode = PAD_MODE_RGMII;
+	case PHY_INTERFACE_MODE_RGMII_RXID:
+		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
 		break;
 
+	case PHY_INTERFACE_MODE_RGMII_ID:
 	case PHY_INTERFACE_MODE_RGMII_TXID:
-		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
+		pad_mode = PAD_MODE_RGMII;
 		break;
 
 	default:
-- 
2.11.0
