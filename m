From: Wan ZongShun <mcuos.com@gmail.com>
Subject: [PATCH] Stmmac: fix a bug when clk_csr == 0x0
Date: Wed, 9 Oct 2013 10:37:33 +0800
Message-ID: <CAKT61h8mcj1Gvp1i8xkM_NS2+fv1WhPtCQaFq7mi=i=JUqT4Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Wan ZongShun <mcuos.com@gmail.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:61511 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288Ab3JIChy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 22:37:54 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so208358pdj.32
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 19:37:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Giuseppe,

According to spec, if csr clock freq is 60-100Mhz, we have to set CR[5:2] = 0000
but when I set the 'plat_dat.clk_csr = 0',acctually, this value is not used
since the driver code judge 'if (!priv->plat->clk_csr)' then go to dynamic tune
the MDC clock. So I add other judge condition.

Signed-off-by: Wan Zongshun <mcuos.com@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 include/linux/stmmac.h                            | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8d4ccd3..a849092c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2741,7 +2741,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct
device *device,
      * set the MDC clock dynamically according to the csr actual
      * clock input.
      */
-    if (!priv->plat->clk_csr)
+    if (priv->plat->dynamic_mdc_clk_en)
         stmmac_clk_csr_set(priv);
     else
         priv->clk_csr = priv->plat->clk_csr;
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index bb5deb0..e2552ce 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -101,6 +101,7 @@ struct plat_stmmacenet_data {
     struct stmmac_mdio_bus_data *mdio_bus_data;
     struct stmmac_dma_cfg *dma_cfg;
     int clk_csr;
+    int dynamic_mdc_clk_en;
     int has_gmac;
     int enh_desc;
     int tx_coe;
-- 
1.8.1.2

-- 
Wan ZongShun.
www.mcuos.com
