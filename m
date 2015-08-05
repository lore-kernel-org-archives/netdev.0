From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCH 4/5] ARM: tegra: use build-in device properties with rfkill_gpio
Date: Wed,  5 Aug 2015 16:39:06 +0300
Message-ID: <1438781947-7952-5-git-send-email-heikki.krogerus@linux.intel.com>
References: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org,
	Alexandre Courbot <gnurou@gmail.com>,
	Thierry Reding <thierry.reding@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index fbe74c6..5d8d3a4 100644
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
+static struct property_entry wifi_rfkill_prop[] = {
+	PROP_ENTRY_STRING("name", "wifi_rfkill"),
+	PROP_ENTRY_STRING("type", "wlan"),
+	{ },
+};
+
+static struct property_set wifi_rfkill_pset = {
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
+	device_add_property_set(&wifi_rfkill_device.dev, &wifi_rfkill_pset);
 	gpiod_add_lookup_table(&wifi_gpio_lookup);
 	platform_device_register(&wifi_rfkill_device);
 }
-- 
2.4.6
