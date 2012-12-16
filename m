From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 1/2] bcma: BCMA_DRIVER_GPIO should depend on GPIOLIB instead of selecting it
Date: Sun, 16 Dec 2012 16:35:35 +0100
Message-ID: <1355672136-24808-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Michael Buesch <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit cf0936b06d8e98a157630e99f647e2ff6d29d7ad ("bcma: add GPIO driver=
")
added BCMA_DRIVER_GPIO, which unconditionally selects GPIOLIB, causing
a Kconfig warning:

warning: (ARCH_REQUIRE_GPIOLIB && SSB_DRIVER_GPIO && BCMA_DRIVER_GPIO &=
& MFD_TC6393XB && FB_VIA) selects GPIOLIB which has unmet direct depend=
encies (ARCH_WANT_OPTIONAL_GPIOLIB || ARCH_REQUIRE_GPIOLIB)

and build failure for m68k/allmodconfig:

In file included from include/linux/bcma/bcma.h:8,
                 from drivers/bcma/bcma_private.h:9,
                 from drivers/bcma/main.c:9:
include/linux/bcma/bcma_driver_chipcommon.h:582: error: field =E2=80=98=
gpio=E2=80=99 has incomplete type
In file included from include/linux/bcma/bcma.h:12,
                 from drivers/bcma/bcma_private.h:9,
                 from drivers/bcma/main.c:9:
include/linux/ssb/ssb.h:440: error: field =E2=80=98gpio=E2=80=99 has in=
complete type
make[4]: *** [drivers/bcma/main.o] Error 1
make[3]: *** [drivers/bcma/] Error 2

Turn the select into a dependency to fix this.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/bcma/Kconfig |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/bcma/Kconfig b/drivers/bcma/Kconfig
index d7b56a8..8b4221c 100644
--- a/drivers/bcma/Kconfig
+++ b/drivers/bcma/Kconfig
@@ -67,8 +67,7 @@ config BCMA_DRIVER_GMAC_CMN
=20
 config BCMA_DRIVER_GPIO
 	bool "BCMA GPIO driver"
-	depends on BCMA
-	select GPIOLIB
+	depends on BCMA && GPIOLIB
 	help
 	  Driver to provide access to the GPIO pins of the bcma bus.
=20
--=20
1.7.0.4
