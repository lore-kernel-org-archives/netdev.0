From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCHv2 3/4] ARM: tegra: use build-in device properties with rfkill_gpio
Date: Mon, 25 Jan 2016 12:03:48 +0300
Message-ID: <1453712629-143317-4-git-send-email-heikki.krogerus@linux.intel.com>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org,
	Alexandre Courbot <gnurou@gmail.com>,
	Thierry Reding <thierry.reding@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:49698 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755839AbcAYJGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 04:06:00 -0500
In-Reply-To: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass the rfkill name and type to the device with properties
instead of driver specific platform data.

Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
CC: Alexandre Courbot <gnurou@gmail.com>
CC: Thierry Reding <thierry.reding@gmail.com>
CC: Stephen Warren <swarren@wwwdotorg.org>
---
 arch/arm/mach-tegra/board-paz00.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/arch/arm/mach-tegra/board-paz00.c b/arch/arm/mach-tegra/board-paz00.c
index 49d1110..52db8bf 100644
--- a/arch/arm/mach-tegra/board-paz00.c
+++ b/arch/arm/mach-tegra/board-paz00.c
@@ -17,23 +17,25 @@
  *
  */
 
+#include <linux/property.h>
 #include <linux/gpio/machine.h>
 #include <linux/platform_device.h>
-#include <linux/rfkill-gpio.h>
 
 #include "board.h"
 
-static struct rfkill_gpio_platform_data wifi_rfkill_platform_data = {
-	.name	= "wifi_rfkill",
-	.type	= RFKILL_TYPE_WLAN,
+static struct property_entry __initdata wifi_rfkill_prop[] = {
+	PROPERTY_ENTRY_STRING("name", "wifi_rfkill"),
+	PROPERTY_ENTRY_STRING("type", "wlan"),
+	{ },
+};
+
+static struct property_set __initdata wifi_rfkill_pset = {
+	.properties = wifi_rfkill_prop,
 };
 
 static struct platform_device wifi_rfkill_device = {
 	.name	= "rfkill_gpio",
 	.id	= -1,
-	.dev	= {
-		.platform_data = &wifi_rfkill_platform_data,
-	},
 };
 
 static struct gpiod_lookup_table wifi_gpio_lookup = {
@@ -47,6 +49,7 @@ static struct gpiod_lookup_table wifi_gpio_lookup = {
 
 void __init tegra_paz00_wifikill_init(void)
 {
+	platform_device_add_properties(&wifi_rfkill_device, &wifi_rfkill_pset);
 	gpiod_add_lookup_table(&wifi_gpio_lookup);
 	platform_device_register(&wifi_rfkill_device);
 }
-- 
2.7.0.rc3
