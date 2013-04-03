From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: [PATCH v5 4/6] ARM: OMAP: USB: Add phy binding information
Date: Wed, 3 Apr 2013 18:23:52 +0530
Message-ID: <1364993634-6378-5-git-send-email-kishon@ti.com>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<cesarb@cesarb.net>, <linux-usb@vger.kernel.org>,
	<linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<tony@atomide.com>, <grant.likely@secretlab.ca>,
	<rob.herring@calxeda.com>, <b-cousson@ti.com>,
	<linux@arm.linux.org.uk>, <eballetbo@gmail.com>,
	<javier@dowhile0.org>, <kishon@ti.com>, <mchehab@redhat.com>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>
To: <balbi@ti.com>, <gregkh@linuxfoundation.org>, <arnd@arndb.de>,
	<akpm@linux-foundation.org>, <swarren@wwwdotorg.org>,
	<sylvester.nawrocki@gmail.com>, <rob@landley.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364993634-6378-1-git-send-email-kishon@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order for controllers to get PHY in case of non dt boot, the phy
binding information should be added in the platform specific
initialization code using phy_bind.

Signed-off-by: Kishon Vijay Abraham I <kishon@ti.com>
---
 arch/arm/mach-omap2/usb-musb.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mach-omap2/usb-musb.c b/arch/arm/mach-omap2/usb-musb.c
index 3242a55..f01bc42 100644
--- a/arch/arm/mach-omap2/usb-musb.c
+++ b/arch/arm/mach-omap2/usb-musb.c
@@ -24,6 +24,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/io.h>
 #include <linux/usb/musb.h>
+#include <linux/phy/phy.h>
 
 #include "omap_device.h"
 #include "soc.h"
@@ -85,8 +86,12 @@ void __init usb_musb_init(struct omap_musb_board_data *musb_board_data)
 	musb_plat.mode = board_data->mode;
 	musb_plat.extvbus = board_data->extvbus;
 
-	if (cpu_is_omap44xx())
+	if (cpu_is_omap44xx()) {
 		musb_plat.has_mailbox = true;
+		phy_bind("musb-hdrc.0.auto", 0, "omap-usb2.1.auto");
+	} else if (cpu_is_omap34xx()) {
+		phy_bind("musb-hdrc.0.auto", 0, "twl4030_usb");
+	}
 
 	if (soc_is_am35xx()) {
 		oh_name = "am35x_otg_hs";
-- 
1.7.10.4
