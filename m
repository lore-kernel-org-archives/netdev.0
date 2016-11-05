From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 4/4] Revert "net: stmmac: allow to split suspend/resume from init/exit callbacks"
Date: Sat,  5 Nov 2016 14:04:52 +0100
Message-ID: <20161105130452.24226-5-manabian@gmail.com>
References: <20161105130452.24226-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, heiko@sntech.de,
        linux-rockchip@lists.infradead.org, vpalatin@chromium.org,
        peppe.cavallaro@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36328 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754151AbcKENFR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2016 09:05:17 -0400
Received: by mail-lf0-f65.google.com with SMTP id o20so6133221lfg.3
        for <netdev@vger.kernel.org>; Sat, 05 Nov 2016 06:05:16 -0700 (PDT)
In-Reply-To: <20161105130452.24226-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of adding hooks inside stmmac_platform it is better to just use
the standard PM callbacks within the specific dwmac-driver. This only
used by the dwmac-rk driver.

This reverts commit cecbc5563a02 ("stmmac: allow to split suspend/resume
from init/exit callbacks").

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 8 ++------
 include/linux/stmmac.h                                | 2 --
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 0a0d6a8..4d544c3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -417,9 +417,7 @@ static int stmmac_pltfr_suspend(struct device *dev)
 	struct platform_device *pdev = to_platform_device(dev);
 
 	ret = stmmac_suspend(dev);
-	if (priv->plat->suspend)
-		priv->plat->suspend(pdev, priv->plat->bsp_priv);
-	else if (priv->plat->exit)
+	if (priv->plat->exit)
 		priv->plat->exit(pdev, priv->plat->bsp_priv);
 
 	return ret;
@@ -438,9 +436,7 @@ static int stmmac_pltfr_resume(struct device *dev)
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	struct platform_device *pdev = to_platform_device(dev);
 
-	if (priv->plat->resume)
-		priv->plat->resume(pdev, priv->plat->bsp_priv);
-	else if (priv->plat->init)
+	if (priv->plat->init)
 		priv->plat->init(pdev, priv->plat->bsp_priv);
 
 	return stmmac_resume(dev);
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 705840e..3537fb3 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -135,8 +135,6 @@ struct plat_stmmacenet_data {
 	void (*bus_setup)(void __iomem *ioaddr);
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
-	void (*suspend)(struct platform_device *pdev, void *priv);
-	void (*resume)(struct platform_device *pdev, void *priv);
 	void *bsp_priv;
 	struct stmmac_axi *axi;
 	int has_gmac4;
-- 
2.10.2
