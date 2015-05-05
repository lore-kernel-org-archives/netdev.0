From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 14/27] net: phy: Allow compile test of GPIO consumers if !GPIOLIB
Date: Tue,  5 May 2015 18:32:30 +0200
Message-ID: <1430843563-18615-14-git-send-email-geert@linux-m68k.org>
References: <1430836404-15513-1-git-send-email-geert@linux-m68k.org>
 <1430843563-18615-1-git-send-email-geert@linux-m68k.org>
Cc: linux-gpio@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430843563-18615-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The GPIO subsystem provides dummy GPIO consumer functions if GPIOLIB is
not enabled. Hence drivers that depend on GPIOLIB, but use GPIO consumer
functionality only, can still be compiled if GPIOLIB is not enabled.

Relax the dependency on GPIOLIB if COMPILE_TEST is enabled, where
appropriate.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/phy/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 8fadaa14b9f0fbd9..f57ccd880ffe30c5 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -138,7 +138,8 @@ config MDIO_BITBANG
 
 config MDIO_GPIO
 	tristate "Support for GPIO lib-based bitbanged MDIO buses"
-	depends on MDIO_BITBANG && GPIOLIB
+	depends on MDIO_BITBANG
+	depends on GPIOLIB || COMPILE_TEST
 	---help---
 	  Supports GPIO lib-based MDIO busses.
 
-- 
1.9.1
