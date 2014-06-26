From: Boris BREZILLON <boris.brezillon@free-electrons.com>
Subject: [PATCH v2 2/2] ARM: at91: remove phy fixup for sama5d3xek boards
Date: Thu, 26 Jun 2014 12:13:35 +0200
Message-ID: <1403777615-25685-3-git-send-email-boris.brezillon@free-electrons.com>
References: <1403777615-25685-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Boris BREZILLON <boris.brezillon@free-electrons.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andrew Victor <linux@maxim.org.za>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403777615-25685-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These board specific delays are now configured through micrel's specific
DT bindings (see Documentation/devicetree/bindings/net/micrel-ksz9021.txt).

Remove this phy fixup registration from sama5 DT machine file to keep it
as generic as possible.

Signed-off-by: Boris BREZILLON <boris.brezillon@free-electrons.com>
---
 arch/arm/mach-at91/board-dt-sama5.c | 22 ----------------------
 1 file changed, 22 deletions(-)

diff --git a/arch/arm/mach-at91/board-dt-sama5.c b/arch/arm/mach-at91/board-dt-sama5.c
index d6fe04b..8c5814f 100644
--- a/arch/arm/mach-at91/board-dt-sama5.c
+++ b/arch/arm/mach-at91/board-dt-sama5.c
@@ -35,30 +35,8 @@ static void __init sama5_dt_timer_init(void)
 	at91sam926x_pit_init();
 }
 
-static int ksz9021rn_phy_fixup(struct phy_device *phy)
-{
-	int value;
-
-	/* Set delay values */
-	value = MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW | 0x8000;
-	phy_write(phy, MICREL_KSZ9021_EXTREG_CTRL, value);
-	value = 0xF2F4;
-	phy_write(phy, MICREL_KSZ9021_EXTREG_DATA_WRITE, value);
-	value = MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW | 0x8000;
-	phy_write(phy, MICREL_KSZ9021_EXTREG_CTRL, value);
-	value = 0x2222;
-	phy_write(phy, MICREL_KSZ9021_EXTREG_DATA_WRITE, value);
-
-	return 0;
-}
-
 static void __init sama5_dt_device_init(void)
 {
-	if (of_machine_is_compatible("atmel,sama5d3xcm") &&
-	    IS_ENABLED(CONFIG_PHYLIB))
-		phy_register_fixup_for_uid(PHY_ID_KSZ9021, MICREL_PHY_ID_MASK,
-			ksz9021rn_phy_fixup);
-
 	of_platform_populate(NULL, of_default_bus_match_table, NULL, NULL);
 }
 
-- 
1.8.3.2
