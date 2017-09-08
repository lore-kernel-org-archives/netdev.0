From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v5 09/10] net: stmmac: snps,dwmac-mdio MDIOs are automatically registered
Date: Fri,  8 Sep 2017 09:11:55 +0200
Message-ID: <20170908071156.5115-10-clabbe.montjoie@gmail.com>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32924 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755119AbdIHHOT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 03:14:19 -0400
In-Reply-To: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stmmac bindings docs said that its mdio node must have
compatible = "snps,dwmac-mdio";
Since dwmac-sun8i does not have any good reasons to not doing it, all
their MDIO node must have it.

Since these compatible is automatically registered, dwmac-sun8i compatible
does not need to be in need_mdio_ids.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index a366b3747eeb..3de5501e34fe 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -311,10 +311,6 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
 	bool mdio = true;
 	static const struct of_device_id need_mdio_ids[] = {
 		{ .compatible = "snps,dwc-qos-ethernet-4.10" },
-		{ .compatible = "allwinner,sun8i-a83t-emac" },
-		{ .compatible = "allwinner,sun8i-h3-emac" },
-		{ .compatible = "allwinner,sun8i-v3s-emac" },
-		{ .compatible = "allwinner,sun50i-a64-emac" },
 	};
 
 	/* If phy-handle property is passed from DT, use it as the PHY */
-- 
2.13.5
