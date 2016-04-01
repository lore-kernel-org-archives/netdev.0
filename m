From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [RESEND PATCH net-next 09/13] stmmac: add new DT platform entries for GMAC4
Date: Fri, 1 Apr 2016 11:37:33 +0200
Message-ID: <1459503457-22569-10-git-send-email-alexandre.torgue@st.com>
References: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:43939 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754441AbcDAJia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 05:38:30 -0400
In-Reply-To: <1459503457-22569-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to support the snps,dwmac-4.00 and snps,dwmac-4.10a
and related features on the platform driver.
See binding doc for further details.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 6605d19..4d302db 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -59,6 +59,8 @@ Optional properties:
 	- snps,fb: fixed-burst
 	- snps,mb: mixed-burst
 	- snps,rb: rebuild INCRx Burst
+	- snps,tso: this enables the TSO feature otherwise it will be managed by
+	    MAC HW capability register.
 - mdio: with compatible = "snps,dwmac-mdio", create and register mdio bus.
 
 Examples:
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index dcbd2a1..6ca32f7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -243,6 +243,13 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 		plat->pmt = 1;
 	}
 
+	if (of_device_is_compatible(np, "snps,dwmac-4.00") ||
+	    of_device_is_compatible(np, "snps,dwmac-4.10a")) {
+		plat->has_gmac4 = 1;
+		plat->pmt = 1;
+		plat->tso_en = of_property_read_bool(np, "snps,tso");
+	}
+
 	if (of_device_is_compatible(np, "snps,dwmac-3.610") ||
 		of_device_is_compatible(np, "snps,dwmac-3.710")) {
 		plat->enh_desc = 1;
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 4bcf5a6..3aa1870 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -138,5 +138,7 @@ struct plat_stmmacenet_data {
 	void (*exit)(struct platform_device *pdev, void *priv);
 	void *bsp_priv;
 	struct stmmac_axi *axi;
+	int has_gmac4;
+	bool tso_en;
 };
 #endif
-- 
1.9.1
