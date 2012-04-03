From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] stmmac: re-add IFF_UNICAST_FLT for dwmac1000
Date: Tue,  3 Apr 2012 19:44:17 +0200
Message-ID: <1333475057-3752-1-git-send-email-mkl@pengutronix.de>
Cc: rayagond@vayavyalabs.com, netdev@vger.kernel.org,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52291 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684Ab2DCRoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 13:44:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit (bfab27a stmmac: add the experimental PCI support) the
IFF_UNICAST_FLT flag has been removed from the stmmac_mac_device_setup()
function. This patch re-adds the flag.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---

Just compile time tested, since I don't have the hardware.
Applies to net-next/master (and v3.3).

regards, Marc

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e85ffbd..07e0c78 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1737,9 +1737,10 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	struct mac_device_info *mac;
 
 	/* Identify the MAC HW device */
-	if (priv->plat->has_gmac)
+	if (priv->plat->has_gmac) {
+		priv->dev->priv_flags |= IFF_UNICAST_FLT;
 		mac = dwmac1000_setup(priv->ioaddr);
-	else
+	} else
 		mac = dwmac100_setup(priv->ioaddr);
 	if (!mac)
 		return -ENOMEM;
-- 
1.7.4.1
