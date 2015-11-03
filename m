From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ssb: mark ssb_bus_register as __maybe_unused
Date: Tue, 03 Nov 2015 16:05:51 +0100
Message-ID: <5928552.0ccybX7Zly@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Michael Buesch <m@bues.ch>, linux-kernel@vger.kernel.org,
	zajec5@gmail.com, Nicolas Ferre <nicolas.ferre@atmel.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
To: netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SoC variant of the ssb code is now optional like the other
ones, which means we can build the framwork without any
front-end, but that results in a warning:

drivers/ssb/main.c:616:12: warning: 'ssb_bus_register' defined but not used [-Wunused-function]

This annotates the ssb_bus_register function as __maybe_unused to
shut up the warning. A configuration like this will not work on
any hardware of course, but we still want this to silently build
without warnings if the configuration is allowed in the first
place.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 845da6e58e19 ("ssb: add Kconfig entry for compiling SoC related code")
----
This showed up on ARM at91_defconfig and sama5_defconfig, so we should probably
change those configurations as well. I can't see why they enable CONFIG_SSB
when they do not use any drivers for this framework.

diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 5d1e9a0fc389..e2ff6b5b2094 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -613,9 +613,10 @@ out:
 	return err;
 }
 
-static int ssb_bus_register(struct ssb_bus *bus,
-			    ssb_invariants_func_t get_invariants,
-			    unsigned long baseaddr)
+static int __maybe_unused
+ssb_bus_register(struct ssb_bus *bus,
+		 ssb_invariants_func_t get_invariants,
+		 unsigned long baseaddr)
 {
 	int err;
 
