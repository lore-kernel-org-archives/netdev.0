From: Su Kang Yin <cantona@cantona.net>
Subject: [PATCH 1/1] r8169.c correct MSIEnable register offset
Date: Wed, 14 Dec 2011 15:13:57 +0800
Message-ID: <CABJLtPHWfRLcbzDFR0ZXe4da3jv04eDZL2CabF1FTcaadoy0xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel@vger.kernel.org, nic_swsd@realtek.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

correct MSIEnable (bit 5) register to Config1 (offset 0x52) instead of
Config2 (offset 0x53)

Signed-off-by: Su Kang Yin <cantona@cantona.net>
---
 drivers/net/ethernet/realtek/r8169.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c
b/drivers/net/ethernet/realtek/r8169.c
index 67bf078..451835c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3430,18 +3430,18 @@ static unsigned rtl_try_msi(struct pci_dev
*pdev, void __iomem *ioaddr,
 			    const struct rtl_cfg_info *cfg)
 {
 	unsigned msi = 0;
-	u8 cfg2;
+	u8 cfg1;

-	cfg2 = RTL_R8(Config2) & ~MSIEnable;
+	cfg1 = RTL_R8(Config1) & ~MSIEnable;
 	if (cfg->features & RTL_FEATURE_MSI) {
 		if (pci_enable_msi(pdev)) {
 			dev_info(&pdev->dev, "no MSI. Back to INTx.\n");
 		} else {
-			cfg2 |= MSIEnable;
+			cfg1 |= MSIEnable;
 			msi = RTL_FEATURE_MSI;
 		}
 	}
-	RTL_W8(Config2, cfg2);
+	RTL_W8(Config1, cfg1);
 	return msi;
 }

-- 
1.7.0.4
