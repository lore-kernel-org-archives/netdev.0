From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH v2 1/4] net: phy: at803x: Document RGMII RX and TX clock delay
 issues
Date: Fri, 21 Jul 2017 13:25:05 +0200
Message-ID: <051653a2-946f-6a0b-4cff-b403d1197038@sigmadesigns.com>
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
Received: from us-smtp-delivery-107.mimecast.com ([216.205.24.107]:42736 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752048AbdGULxF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 07:53:05 -0400
In-Reply-To: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code supports enabling RGMII RX and TX clock delays.
The unstated assumption is that these settings are disabled by
default at reset, which is not the case.

RX clock delay is enabled at reset. And TX clock delay "survives"
across SW resets. Thus, if the bootloader enables TX clock delay,
it will remain enabled at reset in Linux.

Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
---
 drivers/net/phy/at803x.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index c1e52b9dc58d..7a0954513b91 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -283,6 +283,12 @@ static int at803x_config_init(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
+	/*
+	 * NB: This code assumes that RGMII RX clock delay is disabled
+	 * at reset, but actually, RX clock delay is enabled at reset.
+	 * Disabling the delay if it has not been explicitly requested
+	 * breaks boards that rely on the enabled-by-default behavior.
+	 */
 	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID ||
 			phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
 		ret = at803x_enable_rx_delay(phydev);
@@ -290,6 +296,12 @@ static int at803x_config_init(struct phy_device *phydev)
 			return ret;
 	}
 
+	/*
+	 * NB: This code assumes that RGMII TX clock delay is disabled
+	 * at reset, but actually, TX clock delay "survives" across SW
+	 * resets. If the bootloader enables TX clock delay, Linux is
+	 * stuck with that setting.
+	 */
 	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID ||
 			phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
 		ret = at803x_enable_tx_delay(phydev);
-- 
2.11.0
