From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH] net: stmmac: dwmac-sun8i: Use reset exclusive
Date: Fri, 25 Aug 2017 16:38:05 +0200
Message-ID: <20170825143805.21733-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        maxime.ripard@free-electrons.com, wens@csie.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:37966 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756256AbdHYOkW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 10:40:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current dwmac_sun8i module cannot be rmmod/modprobe due to that
the reset controller was not released when removed.

This patch remove ambiguity, by using of_reset_control_get_exclusive and
add the missing reset_control_put().

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
index fffd6d5fc907..675a09629d85 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
@@ -782,6 +782,7 @@ static int sun8i_dwmac_unpower_internal_phy(struct sunxi_priv_data *gmac)
 
 	clk_disable_unprepare(gmac->ephy_clk);
 	reset_control_assert(gmac->rst_ephy);
+	reset_control_put(gmac->rst_ephy);
 	return 0;
 }
 
@@ -942,7 +943,7 @@ static int sun8i_dwmac_probe(struct platform_device *pdev)
 			return -EINVAL;
 		}
 
-		gmac->rst_ephy = of_reset_control_get(plat_dat->phy_node, NULL);
+		gmac->rst_ephy = of_reset_control_get_exclusive(plat_dat->phy_node, NULL);
 		if (IS_ERR(gmac->rst_ephy)) {
 			ret = PTR_ERR(gmac->rst_ephy);
 			if (ret == -EPROBE_DEFER)
-- 
2.13.5
