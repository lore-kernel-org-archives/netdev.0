From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 27/27] net: rfkill: Allow compile test of GPIO consumers if !GPIOLIB
Date: Tue,  5 May 2015 18:32:43 +0200
Message-ID: <1430843563-18615-27-git-send-email-geert@linux-m68k.org>
References: <1430836404-15513-1-git-send-email-geert@linux-m68k.org>
 <1430843563-18615-1-git-send-email-geert@linux-m68k.org>
Cc: linux-gpio@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
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
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/rfkill/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rfkill/Kconfig b/net/rfkill/Kconfig
index 4c10e7e6c9f6ae53..598d374f6a35f714 100644
--- a/net/rfkill/Kconfig
+++ b/net/rfkill/Kconfig
@@ -36,7 +36,8 @@ config RFKILL_REGULATOR
 
 config RFKILL_GPIO
 	tristate "GPIO RFKILL driver"
-	depends on RFKILL && GPIOLIB
+	depends on RFKILL
+	depends on GPIOLIB || COMPILE_TEST
 	default n
 	help
 	  If you say yes here you get support of a generic gpio RFKILL
-- 
1.9.1
