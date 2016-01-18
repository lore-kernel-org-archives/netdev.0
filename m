From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH, RESEND^2] ssb: mark ssb_bus_register as __maybe_unused
Date: Mon, 18 Jan 2016 20:39:56 +0100
Message-ID: <6063400.39vor3soEb@wuerfel>
References: <8128014.DbbgBtKY3z@wuerfel> <8760ywd5fe.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-mips@linux-mips.org,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	linux-kernel@vger.kernel.org, Michael Buesch <m@bues.ch>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8760ywd5fe.fsf@kamboji.qca.qualcomm.com>
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
Acked-by: Michael Buesch <m@bues.ch>
---
Resent to linux-wireless as requested

diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index cde5ff7529eb..d1a750760cf3 100644
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
 
