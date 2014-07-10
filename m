From: Boris BREZILLON <boris.brezillon@free-electrons.com>
Subject: [PATCH v3 2/2] ARM: at91: remove phy fixup for sama5d3xek boards
Date: Thu, 10 Jul 2014 21:59:54 +0200
Message-ID: <1405022394-8311-3-git-send-email-boris.brezillon@free-electrons.com>
References: <1405022394-8311-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Boris BREZILLON <boris.brezillon@free-electrons.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andrew Victor <linux@maxim.org.za>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405022394-8311-1-git-send-email-boris.brezillon@free-electrons.com>
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
index 075ec05..70b2504 100644
--- a/arch/arm/mach-at91/board-dt-sama5.c
+++ b/arch/arm/mach-at91/board-dt-sama5.c
@@ -46,30 +46,8 @@ static void __init at91_dt_init_irq(void)
 	of_irq_init(irq_of_match);
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
