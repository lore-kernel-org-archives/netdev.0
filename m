From: Sonic Zhang <sonic.adi@gmail.com>
Subject: [PATCH 3/3] stmmac: Add an optional device tree property "snps,burst_len"
Date: Thu, 22 Jan 2015 14:55:58 +0800
Message-ID: <1421909758-31359-3-git-send-email-sonic.adi@gmail.com>
References: <1421909758-31359-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adi-buildroot-devel@lists.sourceforge.net>,
	Sonic Zhang <sonic.zhang@analog.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0078.outbound.protection.outlook.com ([157.56.110.78]:21859
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754316AbbAVHcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 02:32:55 -0500
In-Reply-To: <1421909758-31359-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

This property define the AXI bug lenth.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt   |    1 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    3 +++
 2 files changed, 4 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index c41afd9..8ca65ce 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -43,6 +43,7 @@ Optional properties:
   available this clock is used for programming the Timestamp Addend Register.
   If not passed then the system clock will be used and this is fine on some
   platforms.
+- snps,burst_len: The AXI burst lenth value of the AXI BUS MODE register.
 
 Examples:
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 3039de2..a20cf0d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -234,6 +234,9 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 			of_property_read_bool(np, "snps,fixed-burst");
 		dma_cfg->mixed_burst =
 			of_property_read_bool(np, "snps,mixed-burst");
+		of_property_read_u32(np, "snps,burst_len", &dma_cfg->burst_len);
+		if (dma_cfg->burst_len < 0 || dma_cfg->burst_len > 256)
+			dma_cfg->burst_len = 0;
 	}
 	plat->force_thresh_dma_mode = of_property_read_bool(np, "snps,force_thresh_dma_mode");
 	if (plat->force_thresh_dma_mode) {
-- 
1.7.9.5
