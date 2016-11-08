From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v2] irqchip/renesas-irqc: Postpone driver initialization
Date: Tue,  8 Nov 2016 20:35:47 +0100
Message-ID: <1478633747-26878-1-git-send-email-geert+renesas@glider.be>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Thomas Gleixner <tglx@linutronix.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Marc Zyngier <marc.zyngier@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the renesas-irqc driver uses postcore_initcall().

However, the new CPG/MSSR driver uses subsys_initcall(). Hence the
IRQC's probe will be deferred, which causes the Micrel Ethernet PHY to
not find its interrupt on R-Car Gen2 and RZ/G, as the of_mdio subsystem
does not support deferred probe yet.

Replace postcore_initcall() by device_initcall() to work around this.

Note that on R-Mobile APE6, where the PFC/GPIO combo uses the IRQC as
its parent interrupt controller, this does cause a few additional probe
deferrals (for SCIFA0, SD0, SD1, and MMC). But the affected drivers
handle that fine.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Tested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---
v2:
  - Drop RFC state,
  - Add Tested-by,
  - Improved description.
---
 drivers/irqchip/irq-renesas-irqc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/irqchip/irq-renesas-irqc.c b/drivers/irqchip/irq-renesas-irqc.c
index 52304b139aa46a60..992849e54d00ea77 100644
--- a/drivers/irqchip/irq-renesas-irqc.c
+++ b/drivers/irqchip/irq-renesas-irqc.c
@@ -295,7 +295,7 @@ static int __init irqc_init(void)
 {
 	return platform_driver_register(&irqc_device_driver);
 }
-postcore_initcall(irqc_init);
+device_initcall(irqc_init);
 
 static void __exit irqc_exit(void)
 {
-- 
1.9.1
