From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 2/7] net: ethernet: stmmac: dwmac-sti: fix probe error path
Date: Wed, 30 Nov 2016 15:29:50 +0100
Message-ID: <1480516195-27696-3-git-send-email-johan@kernel.org>
References: <1480516195-27696-1-git-send-email-johan@kernel.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33485 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757109AbcK3Ocd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 09:32:33 -0500
In-Reply-To: <1480516195-27696-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure to disable clocks before returning on late probe errors.

Fixes: 8387ee21f972 ("stmmac: dwmac-sti: turn setup callback into a
probe function")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 58c05acc2aab..a1ce018bf844 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -365,7 +365,16 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 	if (ret)
 		return ret;
 
-	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+	if (ret)
+		goto err_dwmac_exit;
+
+	return 0;
+
+err_dwmac_exit:
+	sti_dwmac_exit(pdev, plat_dat->bsp_priv);
+
+	return ret;
 }
 
 static const struct sti_dwmac_of_data stih4xx_dwmac_data = {
-- 
2.7.3
