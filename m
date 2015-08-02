From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH v2 04/11] net: phy: Allow compile test of GPIO consumers if !GPIOLIB
Date: Sun,  2 Aug 2015 11:09:50 +0200
Message-ID: <1438506590-31630-1-git-send-email-geert@linux-m68k.org>
References: <1438506475-31012-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	linux-gpio@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from andre.telenet-ops.be ([195.130.132.53]:42111 "EHLO
	andre.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbbHBJJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 05:09:51 -0400
In-Reply-To: <1438506475-31012-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GPIO subsystem provides dummy GPIO consumer functions if GPIOLIB is
not enabled. Hence drivers that depend on GPIOLIB, but use GPIO consumer
functionality only, can still be compiled if GPIOLIB is not enabled.

Relax the dependency on GPIOLIB if COMPILE_TEST is enabled, where
appropriate.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Linus Walleij <linus.walleij@linaro.org>
---
v2:
  - Add Acked-by.
---
 drivers/net/phy/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 8ef81914422049ff..b98b4a2b8922a912 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -142,7 +142,8 @@ config MDIO_BITBANG
 
 config MDIO_GPIO
 	tristate "Support for GPIO lib-based bitbanged MDIO buses"
-	depends on MDIO_BITBANG && GPIOLIB
+	depends on MDIO_BITBANG
+	depends on GPIOLIB || COMPILE_TEST
 	---help---
 	  Supports GPIO lib-based MDIO busses.
 
-- 
1.9.1
