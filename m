From: Chen Baozi <cbz@baozis.org>
Subject: [PATCH 3/3] stmmac: Add AXI burst length support to platform device.
Date: Sat,  7 Feb 2015 13:07:16 +0800
Message-ID: <1423285636-8623-4-git-send-email-cbz@baozis.org>
References: <1423285636-8623-1-git-send-email-cbz@baozis.org>
Cc: Chen Baozi <cbz@baozis.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423285636-8623-1-git-send-email-cbz@baozis.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The AXI Bus Mode Register controls the AXI master behavior. It is mainly
used to control the burst splitting and the number of outstanding requests.
This register is present and valid only in GMAC-AXI configuration. The old
driver only supports this feature on PCI devices. This patch adds an
'snps,apl' properties in DT to enable it on platform devices.

Signed-off-by: Chen Baozi <chenbaozi@kylinos.com.cn>
---
 Documentation/devicetree/bindings/net/stmmac.txt      | 1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index c41afd9..8f3c834 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -43,6 +43,7 @@ Optional properties:
   available this clock is used for programming the Timestamp Addend Register.
   If not passed then the system clock will be used and this is fine on some
   platforms.
+- snps,abl: AXI Burst Length
 
 Examples:
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 3039de2..abbc897 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -230,6 +230,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 			return -ENOMEM;
 		plat->dma_cfg = dma_cfg;
 		of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
+		of_property_read_u32(np, "snps,abl", &dma_cfg->burst_len);
 		dma_cfg->fixed_burst =
 			of_property_read_bool(np, "snps,fixed-burst");
 		dma_cfg->mixed_burst =
-- 
2.1.4
