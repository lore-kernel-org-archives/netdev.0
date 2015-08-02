From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH v2 11/11] net: rfkill: Allow compile test of GPIO consumers if !GPIOLIB
Date: Sun,  2 Aug 2015 11:09:54 +0200
Message-ID: <1438506594-31931-1-git-send-email-geert@linux-m68k.org>
References: <1438506475-31012-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	linux-gpio@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from michel.telenet-ops.be ([195.130.137.88]:35162 "EHLO
	michel.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbbHBJJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 05:09:55 -0400
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
