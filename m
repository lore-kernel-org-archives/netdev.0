From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: dsa: include gpio consumer header file
Date: Tue, 24 Nov 2015 12:34:49 +0100
Message-ID: <6383467.TZ5s6u4A6T@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	linux-kernel@vger.kernel.org, linus.walleij@linaro.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:49913 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbbKXLfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 06:35:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the introduction of the switch gpio reset API, I'm getting
build errors in configurations that disable CONFIG_GPIOLIB:

net/dsa/dsa.c:783:16: error: implicit declaration of function 'gpio_to_desc' [-Werror=implicit-function-declaration]

The reason is that linux/gpio/consumer.h is not automatically
included without gpiolib support. This adds an explicit #include
statement to make it compile in all configurations. The reset
functionality will not work without gpiolib, which is what you
get when disabling the feature.

As far as I can tell, gpiolib is supported on all architectures
on which you can have DSA at the moment.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: cc30c16344fc ("net: dsa: Add support for a switch reset gpio")

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0b5565f923cc..b7448c8490ac 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -24,6 +24,7 @@
 #include <linux/of_gpio.h>
 #include <linux/sysfs.h>
 #include <linux/phy_fixed.h>
+#include <linux/gpio/consumer.h>
 #include "dsa_priv.h"
 
 char dsa_driver_version[] = "0.1";
