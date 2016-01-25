From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCHv2 4/4] net: rfkill: gpio: remove rfkill_gpio_platform_data
Date: Mon, 25 Jan 2016 12:03:49 +0300
Message-ID: <1453712629-143317-5-git-send-email-heikki.krogerus@linux.intel.com>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:49698 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755857AbcAYJGC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 04:06:02 -0500
In-Reply-To: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No more users for it.

Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
---
 include/linux/rfkill-gpio.h | 37 -------------------------------------
 net/rfkill/Kconfig          |  3 +--
 net/rfkill/rfkill-gpio.c    |  8 --------
 3 files changed, 1 insertion(+), 47 deletions(-)
 delete mode 100644 include/linux/rfkill-gpio.h

diff --git a/include/linux/rfkill-gpio.h b/include/linux/rfkill-gpio.h
deleted file mode 100644
index 20bcb55..0000000
--- a/include/linux/rfkill-gpio.h
+++ /dev/null
@@ -1,37 +0,0 @@
-/*
- * Copyright (c) 2011, NVIDIA Corporation.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along
- * with this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
- */
-
-
-#ifndef __RFKILL_GPIO_H
-#define __RFKILL_GPIO_H
-
-#include <linux/types.h>
-#include <linux/rfkill.h>
-
-/**
- * struct rfkill_gpio_platform_data - platform data for rfkill gpio device.
- * for unused gpio's, the expected value is -1.
- * @name:		name for the gpio rf kill instance
- */
-
-struct rfkill_gpio_platform_data {
-	char			*name;
-	enum rfkill_type	type;
-};
-
-#endif /* __RFKILL_GPIO_H */
diff --git a/net/rfkill/Kconfig b/net/rfkill/Kconfig
index 598d374..868f1ad 100644
--- a/net/rfkill/Kconfig
+++ b/net/rfkill/Kconfig
@@ -41,5 +41,4 @@ config RFKILL_GPIO
 	default n
 	help
 	  If you say yes here you get support of a generic gpio RFKILL
-	  driver. The platform should fill in the appropriate fields in the
-	  rfkill_gpio_platform_data structure and pass that to the driver.
+	  driver.
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 1a9c031..76c01cb 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -27,8 +27,6 @@
 #include <linux/acpi.h>
 #include <linux/gpio/consumer.h>
 
-#include <linux/rfkill-gpio.h>
-
 struct rfkill_gpio_data {
 	const char		*name;
 	enum rfkill_type	type;
@@ -89,7 +87,6 @@ static int rfkill_gpio_acpi_probe(struct device *dev,
 
 static int rfkill_gpio_probe(struct platform_device *pdev)
 {
-	struct rfkill_gpio_platform_data *pdata = pdev->dev.platform_data;
 	struct rfkill_gpio_data *rfkill;
 	struct gpio_desc *gpio;
 	const char *type_name;
@@ -111,11 +108,6 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		ret = rfkill_gpio_acpi_probe(&pdev->dev, rfkill);
 		if (ret)
 			return ret;
-	} else if (pdata) {
-		rfkill->name = pdata->name;
-		rfkill->type = pdata->type;
-	} else {
-		return -ENODEV;
 	}
 
 	rfkill->clk = devm_clk_get(&pdev->dev, NULL);
-- 
2.7.0.rc3
