From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] net: rfkill: gpio: Switch to devm_acpi_dev_add_driver_gpios()
Date: Sat, 10 Jun 2017 22:10:34 +0300
Message-ID: <20170610191034.53635-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:2949 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751563AbdFJTLi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Jun 2017 15:11:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to use managed variant of acpi_dev_add_driver_gpios() to simplify
error path and fix potentially wrong assingment if ->probe() fails.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 net/rfkill/rfkill-gpio.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 76c01cbd56e3..41bd496531d4 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -81,8 +81,7 @@ static int rfkill_gpio_acpi_probe(struct device *dev,
 
 	rfkill->type = (unsigned)id->driver_data;
 
-	return acpi_dev_add_driver_gpios(ACPI_COMPANION(dev),
-					 acpi_rfkill_default_gpios);
+	return devm_acpi_dev_add_driver_gpios(dev, acpi_rfkill_default_gpios);
 }
 
 static int rfkill_gpio_probe(struct platform_device *pdev)
@@ -154,8 +153,6 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
 	rfkill_unregister(rfkill->rfkill_dev);
 	rfkill_destroy(rfkill->rfkill_dev);
 
-	acpi_dev_remove_driver_gpios(ACPI_COMPANION(&pdev->dev));
-
 	return 0;
 }
 
-- 
2.11.0
