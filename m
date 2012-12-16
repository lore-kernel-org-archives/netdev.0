From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 2/2] ssb: SSB_DRIVER_GPIO should depend on GPIOLIB instead of selecting it
Date: Sun, 16 Dec 2012 16:35:36 +0100
Message-ID: <1355672136-24808-2-git-send-email-geert@linux-m68k.org>
References: <1355672136-24808-1-git-send-email-geert@linux-m68k.org>
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
In-Reply-To: <1355672136-24808-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit ec43b08b5733494ad88aa618ecdf534320dd8207 ("ssb: add GPIO driver"=
)
added SSB_DRIVER_GPIO, which unconditionally selects GPIOLIB, causing
a Kconfig warning:

warning: (ARCH_REQUIRE_GPIOLIB && SSB_DRIVER_GPIO && BCMA_DRIVER_GPIO &=
& MFD_TC6393XB && FB_VIA) selects GPIOLIB which has unmet direct depend=
encies (ARCH_WANT_OPTIONAL_GPIOLIB || ARCH_REQUIRE_GPIOLIB)

and build failure for m68k/allmodconfig:

In file included from drivers/ssb/ssb_private.h:5,
                 from drivers/ssb/main.c:12:
include/linux/ssb/ssb.h:440: error: field =E2=80=98gpio=E2=80=99 has in=
complete type
make[4]: *** [drivers/ssb/main.o] Error 1
make[3]: *** [drivers/ssb/] Error 2

Turn the select into a dependency to fix this.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/ssb/Kconfig |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
index ff3c8a2..5d6f2ec 100644
--- a/drivers/ssb/Kconfig
+++ b/drivers/ssb/Kconfig
@@ -162,8 +162,7 @@ config SSB_DRIVER_GIGE
=20
 config SSB_DRIVER_GPIO
 	bool "SSB GPIO driver"
-	depends on SSB
-	select GPIOLIB
+	depends on SSB && GPIOLIB
 	help
 	  Driver to provide access to the GPIO pins on the bus.
=20
--=20
1.7.0.4
