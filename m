From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 09/13] timer: Remove users of expire and data arguments to DEFINE_TIMER
Date: Wed,  4 Oct 2017 16:27:03 -0700
Message-ID: <1507159627-127660-10-git-send-email-keescook@chromium.org>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Ralf Baechle <ralf@linux-mips.org>,
        Wim Van Sebroeck <wim@iguana.be>,
        Guenter Roeck <linux@roeck-us.net>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-mips@linux-mips.org, linux-watchdog@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Chris Metcalf <cmetcalf@mellanox.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Harish Patil <harish.patil@cavium.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        John Stultz <john.stultz@linaro.org>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Len B
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507159627-127660-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The expire and data arguments of DEFINE_TIMER are only used in two places
and are ignored by the code (malta-display.c only uses mod_timer(),
never add_timer(), so the preset expires value is ignored). Set both
sets of arguments to zero.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Wim Van Sebroeck <wim@iguana.be>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-mips@linux-mips.org
Cc: linux-watchdog@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/mips/mti-malta/malta-display.c | 6 +++---
 drivers/watchdog/alim7101_wdt.c     | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/mips/mti-malta/malta-display.c b/arch/mips/mti-malta/malta-display.c
index d4f807191ecd..ac813158b9b8 100644
--- a/arch/mips/mti-malta/malta-display.c
+++ b/arch/mips/mti-malta/malta-display.c
@@ -36,10 +36,10 @@ void mips_display_message(const char *str)
 	}
 }
 
-static void scroll_display_message(unsigned long data);
-static DEFINE_TIMER(mips_scroll_timer, scroll_display_message, HZ, 0);
+static void scroll_display_message(unsigned long unused);
+static DEFINE_TIMER(mips_scroll_timer, scroll_display_message, 0, 0);
 
-static void scroll_display_message(unsigned long data)
+static void scroll_display_message(unsigned long unused)
 {
 	mips_display_message(&display_string[display_count++]);
 	if (display_count == max_display_count)
diff --git a/drivers/watchdog/alim7101_wdt.c b/drivers/watchdog/alim7101_wdt.c
index 665e0e7dfe1e..3c1f6ac68ea9 100644
--- a/drivers/watchdog/alim7101_wdt.c
+++ b/drivers/watchdog/alim7101_wdt.c
@@ -71,7 +71,7 @@ MODULE_PARM_DESC(use_gpio,
 		"Use the gpio watchdog (required by old cobalt boards).");
 
 static void wdt_timer_ping(unsigned long);
-static DEFINE_TIMER(timer, wdt_timer_ping, 0, 1);
+static DEFINE_TIMER(timer, wdt_timer_ping, 0, 0);
 static unsigned long next_heartbeat;
 static unsigned long wdt_is_open;
 static char wdt_expect_close;
@@ -87,7 +87,7 @@ MODULE_PARM_DESC(nowayout,
  *	Whack the dog
  */
 
-static void wdt_timer_ping(unsigned long data)
+static void wdt_timer_ping(unsigned long unused)
 {
 	/* If we got a heartbeat pulse within the WDT_US_INTERVAL
 	 * we agree to ping the WDT
-- 
2.7.4
