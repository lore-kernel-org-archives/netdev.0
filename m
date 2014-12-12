From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net] net: smc91x: Fix build without gpiolib
Date: Fri, 12 Dec 2014 17:00:22 +0100
Message-ID: <1418400022-6264-1-git-send-email-tklauser@distanz.ch>
Cc: "David S. Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>, netdev@vger.kernel.org
To: Nicolas Pitre <nico@fluxnic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:58694 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753665AbaLLQA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 11:00:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If GPIOLIB=n the following build error occurs:

Since the toggling of the GPIOs is an optional feature, define
try_toggle_control_gpio only if GPIOLIB is enabled.

Fixes: 7d2911c4381 ("net: smc91x: Fix gpios for device tree based booting")
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/smsc/smc91x.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 6cc3cf6..050bcb6 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2193,6 +2193,7 @@ MODULE_DEVICE_TABLE(of, smc91x_match);
 /**
  * of_try_set_control_gpio - configure a gpio if it exists
  */
+#ifdef CONFIG_GPIOLIB
 static int try_toggle_control_gpio(struct device *dev,
 				   struct gpio_desc **desc,
 				   const char *name, int index,
@@ -2224,7 +2225,16 @@ static int try_toggle_control_gpio(struct device *dev,
 
 	return 0;
 }
-#endif
+#else
+static int try_toggle_control_gpio(struct device *dev,
+				   struct gpio_desc **desc,
+				   const char *name, int index,
+				   int value, unsigned int nsdelay)
+{
+	return 0;
+}
+#endif /* CONFIG_GPIOLIB */
+#endif /* CONFIG_OF */
 
 /*
  * smc_init(void)
-- 
2.2.0
