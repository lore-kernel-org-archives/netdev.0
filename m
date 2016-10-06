From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH v2] ethernet: qualcomm: QCOM_EMAC should depend on HAS_DMA and HAS_IOMEM
Date: Thu,  6 Oct 2016 16:44:53 +0200
Message-ID: <1475765093-15536-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
        Timur Tabi <timur@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

    drivers/built-in.o: In function `emac_probe':
    emac.c:(.text+0x3780b8): undefined reference to `bad_dma_ops'
    emac.c:(.text+0x3780e2): undefined reference to `bad_dma_ops'
    emac.c:(.text+0x378112): undefined reference to `bad_dma_ops'
    emac.c:(.text+0x378146): undefined reference to `bad_dma_ops'
    emac.c:(.text+0x37816e): undefined reference to `bad_dma_ops'
    drivers/built-in.o:emac.c:(.text+0x37819a): more undefined references to `bad_dma_ops' follow

If NO_IOMEM=y:

    drivers/net/ethernet/qualcomm/emac/emac.c: In function ‘emac_remove’:
    drivers/net/ethernet/qualcomm/emac/emac.c:736:3: error: implicit declaration of function ‘iounmap’ [-Werror=implicit-function-declaration]
       iounmap(adpt->phy.digital);
       ^

Add dependencies on HAS_DMA and HAS_IOMEM to fix this.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
v2:
  - Add dependency on HAS_IOMEM for UML.
---
 drivers/net/ethernet/qualcomm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
index 9ba568db576fb0e6..d7720bf92d49658a 100644
--- a/drivers/net/ethernet/qualcomm/Kconfig
+++ b/drivers/net/ethernet/qualcomm/Kconfig
@@ -26,6 +26,7 @@ config QCA7000
 
 config QCOM_EMAC
 	tristate "Qualcomm Technologies, Inc. EMAC Gigabit Ethernet support"
+	depends on HAS_DMA && HAS_IOMEM
 	select CRC32
 	select PHYLIB
 	---help---
-- 
1.9.1
