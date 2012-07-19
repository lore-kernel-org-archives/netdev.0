From: Andres Salomon <dilinger@queued.net>
Subject: [PATCH RESEND 2/9] drivers: OLPC: update various drivers to include
 olpc-ec.h
Date: Wed, 18 Jul 2012 21:38:46 -0700
Message-ID: <20120718213846.2d8d274f@dev.queued.net>
References: <20120718213713.232e4161@dev.queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Daniel Drake <dsd@laptop.org>,
 libertas-dev@lists.infradead.org, Dan Williams <dcbw@redhat.com>,
 netdev@vger.kernel.org, Jon Nettleton <jon.nettleton@gmail.com>,
 x86@kernel.org, linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 platform-driver-x86@vger.kernel.org, "Richard A.
 Smith" <richard@laptop.org>, Paul Fox <pgf@laptop.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Anton Vorontsov <cbou@mail.ru>, "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>, Chris Ball <cjb@laptop.org>,
 David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 "John W. Linville" <linville@tuxdriver.com>, Matthew Garrett <mjg@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20120718213713.232e4161@dev.queued.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org


Switch over to using olpc-ec.h in multiple steps, so as not to break builds.
This covers every driver that calls olpc_ec_cmd().

Signed-off-by: Andres Salomon <dilinger@queued.net>
---
 arch/x86/include/asm/olpc.h            |    1 -
 arch/x86/platform/olpc/olpc-xo1-pm.c   |    1 +
 arch/x86/platform/olpc/olpc-xo1-sci.c  |    1 +
 arch/x86/platform/olpc/olpc-xo15-sci.c |    1 +
 arch/x86/platform/olpc/olpc.c          |    1 +
 drivers/net/wireless/libertas/if_usb.c |    1 +
 drivers/platform/x86/xo1-rfkill.c      |    3 +--
 drivers/power/olpc_battery.c           |    1 +
 drivers/staging/olpc_dcon/olpc_dcon.c  |    1 +
 9 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/olpc.h b/arch/x86/include/asm/olpc.h
index 513e999..5b28f3e 100644
--- a/arch/x86/include/asm/olpc.h
+++ b/arch/x86/include/asm/olpc.h
@@ -4,7 +4,6 @@
 #define _ASM_X86_OLPC_H
 
 #include <asm/geode.h>
-#include <linux/olpc-ec.h>
 
 struct olpc_platform_t {
 	int flags;
diff --git a/arch/x86/platform/olpc/olpc-xo1-pm.c b/arch/x86/platform/olpc/olpc-xo1-pm.c
index 0ce8616c..8054b64 100644
--- a/arch/x86/platform/olpc/olpc-xo1-pm.c
+++ b/arch/x86/platform/olpc/olpc-xo1-pm.c
@@ -18,6 +18,7 @@
 #include <linux/pm.h>
 #include <linux/mfd/core.h>
 #include <linux/suspend.h>
+#include <linux/olpc-ec.h>
 
 #include <asm/io.h>
 #include <asm/olpc.h>
diff --git a/arch/x86/platform/olpc/olpc-xo1-sci.c b/arch/x86/platform/olpc/olpc-xo1-sci.c
index 04b8c73..63d4aa4 100644
--- a/arch/x86/platform/olpc/olpc-xo1-sci.c
+++ b/arch/x86/platform/olpc/olpc-xo1-sci.c
@@ -23,6 +23,7 @@
 #include <linux/power_supply.h>
 #include <linux/suspend.h>
 #include <linux/workqueue.h>
+#include <linux/olpc-ec.h>
 
 #include <asm/io.h>
 #include <asm/msr.h>
diff --git a/arch/x86/platform/olpc/olpc-xo15-sci.c b/arch/x86/platform/olpc/olpc-xo15-sci.c
index 23e5b9d..9899fef 100644
--- a/arch/x86/platform/olpc/olpc-xo15-sci.c
+++ b/arch/x86/platform/olpc/olpc-xo15-sci.c
@@ -13,6 +13,7 @@
 #include <linux/slab.h>
 #include <linux/workqueue.h>
 #include <linux/power_supply.h>
+#include <linux/olpc-ec.h>
 
 #include <acpi/acpi_bus.h>
 #include <acpi/acpi_drivers.h>
diff --git a/arch/x86/platform/olpc/olpc.c b/arch/x86/platform/olpc/olpc.c
index 796e199..a3fa180 100644
--- a/arch/x86/platform/olpc/olpc.c
+++ b/arch/x86/platform/olpc/olpc.c
@@ -22,6 +22,7 @@
 #include <linux/syscore_ops.h>
 #include <linux/debugfs.h>
 #include <linux/mutex.h>
+#include <linux/olpc-ec.h>
 
 #include <asm/geode.h>
 #include <asm/setup.h>
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index cd3b0d4..a9828b1 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -10,6 +10,7 @@
 #include <linux/netdevice.h>
 #include <linux/slab.h>
 #include <linux/usb.h>
+#include <linux/olpc-ec.h>
 
 #ifdef CONFIG_OLPC
 #include <asm/olpc.h>
diff --git a/drivers/platform/x86/xo1-rfkill.c b/drivers/platform/x86/xo1-rfkill.c
index b57ad86..1da13ed 100644
--- a/drivers/platform/x86/xo1-rfkill.c
+++ b/drivers/platform/x86/xo1-rfkill.c
@@ -12,8 +12,7 @@
 #include <linux/module.h>
 #include <linux/platform_device.h>
 #include <linux/rfkill.h>
-
-#include <asm/olpc.h>
+#include <linux/olpc-ec.h>
 
 static bool card_blocked;
 
diff --git a/drivers/power/olpc_battery.c b/drivers/power/olpc_battery.c
index 7385092..eaf917d 100644
--- a/drivers/power/olpc_battery.c
+++ b/drivers/power/olpc_battery.c
@@ -17,6 +17,7 @@
 #include <linux/power_supply.h>
 #include <linux/jiffies.h>
 #include <linux/sched.h>
+#include <linux/olpc-ec.h>
 #include <asm/olpc.h>
 
 
diff --git a/drivers/staging/olpc_dcon/olpc_dcon.c b/drivers/staging/olpc_dcon/olpc_dcon.c
index 992275c..2c4bd74 100644
--- a/drivers/staging/olpc_dcon/olpc_dcon.c
+++ b/drivers/staging/olpc_dcon/olpc_dcon.c
@@ -27,6 +27,7 @@
 #include <linux/uaccess.h>
 #include <linux/ctype.h>
 #include <linux/reboot.h>
+#include <linux/olpc-ec.h>
 #include <asm/tsc.h>
 #include <asm/olpc.h>
 
-- 
1.7.2.5
