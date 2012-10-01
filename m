From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH 2/2] tg3: fix build-time dependency with IS_DEPENDENCY_SATISFIED()
Date: Mon,  1 Oct 2012 14:21:20 +0200
Message-ID: <1349094080-769-2-git-send-email-anisse@astier.eu>
References: <1349094080-769-1-git-send-email-anisse@astier.eu>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Michal Marek <mmarek@suse.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Anisse Astier <anisse@astier.eu>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349094080-769-1-git-send-email-anisse@astier.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_TIGON3=y and CONFIG_HWMON=y, we will get this error:
  LD      init/built-in.o
drivers/built-in.o: In function `tg3_hwmon_open':
tg3.c:(.text+0xc1d12): undefined reference to `hwmon_device_register'
drivers/built-in.o: In function `tg3_close':
tg3.c:(.text+0xc2e7f): undefined reference to `hwmon_device_unregister'
make: *** [vmlinux] Error 1

Use the new IS_DEPENDENCY_SATISFIED() facility to solve this problem.

Signed-off-by: Anisse Astier <anisse@astier.eu>
---
 drivers/net/ethernet/broadcom/tg3.c |    8 ++++----
 drivers/net/ethernet/broadcom/tg3.h |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index bf906c5..cc81a59 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -44,7 +44,7 @@
 #include <linux/prefetch.h>
 #include <linux/dma-mapping.h>
 #include <linux/firmware.h>
-#if IS_ENABLED(CONFIG_HWMON)
+#if IS_DEPENDENCY_SATISFIED(CONFIG_TIGON3, CONFIG_HWMON)
 #include <linux/hwmon.h>
 #include <linux/hwmon-sysfs.h>
 #endif
@@ -9517,7 +9517,7 @@ static int tg3_init_hw(struct tg3 *tp, int reset_phy)
 	return tg3_reset_hw(tp, reset_phy);
 }
 
-#if IS_ENABLED(CONFIG_HWMON)
+#if IS_DEPENDENCY_SATISFIED(CONFIG_TIGON3, CONFIG_HWMON)
 static void tg3_sd_scan_scratchpad(struct tg3 *tp, struct tg3_ocir *ocir)
 {
 	int i;
@@ -9574,7 +9574,7 @@ static const struct attribute_group tg3_group = {
 
 static void tg3_hwmon_close(struct tg3 *tp)
 {
-#if IS_ENABLED(CONFIG_HWMON)
+#if IS_DEPENDENCY_SATISFIED(CONFIG_TIGON3, CONFIG_HWMON)
 	if (tp->hwmon_dev) {
 		hwmon_device_unregister(tp->hwmon_dev);
 		tp->hwmon_dev = NULL;
@@ -9585,7 +9585,7 @@ static void tg3_hwmon_close(struct tg3 *tp)
 
 static void tg3_hwmon_open(struct tg3 *tp)
 {
-#if IS_ENABLED(CONFIG_HWMON)
+#if IS_DEPENDENCY_SATISFIED(CONFIG_TIGON3, CONFIG_HWMON)
 	int i, err;
 	u32 size = 0;
 	struct pci_dev *pdev = tp->pdev;
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 6d52cb2..867dae1 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3252,7 +3252,7 @@ struct tg3 {
 	const struct firmware		*fw;
 	u32				fw_len; /* includes BSS */
 
-#if IS_ENABLED(CONFIG_HWMON)
+#if IS_DEPENDENCY_SATISFIED(CONFIG_TIGON3, CONFIG_HWMON)
 	struct device			*hwmon_dev;
 #endif
 };
-- 
1.7.10.3
