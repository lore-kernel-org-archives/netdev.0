From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 1/2] arch/blackfin: don't generate random mac in bfin_get_ether_addr()
Date: Thu, 16 Feb 2012 18:09:30 +0100
Message-ID: <1329412171-20704-2-git-send-email-danny.kukawka@bisect.de>
References: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	uclinux-dist-devel@blackfin.uclinux.org,
	"David S. Miller" <davem@davemloft.net>,
	Mike Frysinger <vapier@gentoo.org>,
	Bob Liu <lliubbo@gmail.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Steven Miao <realmz6@gmail.com>,
	Lars-Peter Clausen <lars@metafoo.de>,
	Scott Jiang <scott.jiang@analog.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changed bfin_get_ether_addr() to return a state and to
set no random mac address if the board don't provide one.

Let the caller of bfin_get_ether_addr() set a random mac
address if the return value is not 0.

v2: don't set random mac in bfin_get_ether_addr()

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 arch/blackfin/mach-bf518/boards/ezbrd.c      |    3 ++-
 arch/blackfin/mach-bf518/boards/tcm-bf518.c  |    5 ++---
 arch/blackfin/mach-bf527/boards/ad7160eval.c |    3 ++-
 arch/blackfin/mach-bf527/boards/cm_bf527.c   |    5 ++---
 arch/blackfin/mach-bf527/boards/ezbrd.c      |    3 ++-
 arch/blackfin/mach-bf527/boards/ezkit.c      |    3 ++-
 arch/blackfin/mach-bf527/boards/tll6527m.c   |    3 ++-
 arch/blackfin/mach-bf537/boards/cm_bf537e.c  |    5 ++---
 arch/blackfin/mach-bf537/boards/cm_bf537u.c  |    5 ++---
 arch/blackfin/mach-bf537/boards/dnp5370.c    |    3 ++-
 arch/blackfin/mach-bf537/boards/pnav10.c     |    5 ++---
 arch/blackfin/mach-bf537/boards/stamp.c      |    3 ++-
 arch/blackfin/mach-bf537/boards/tcm_bf537.c  |    5 ++---
 13 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/arch/blackfin/mach-bf518/boards/ezbrd.c b/arch/blackfin/mach-bf518/boards/ezbrd.c
index a2d96d3..a173957 100644
--- a/arch/blackfin/mach-bf518/boards/ezbrd.c
+++ b/arch/blackfin/mach-bf518/boards/ezbrd.c
@@ -821,7 +821,7 @@ void native_machine_restart(char *cmd)
 		bfin_reset_boot_spi_cs(P_DEFAULT_BOOT_SPI_CS);
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	/* the MAC is stored in OTP memory page 0xDF */
 	u32 ret;
@@ -834,5 +834,6 @@ void bfin_get_ether_addr(char *addr)
 		for (ret = 0; ret < 6; ++ret)
 			addr[ret] = otp_mac_p[5 - ret];
 	}
+	return 0;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf518/boards/tcm-bf518.c b/arch/blackfin/mach-bf518/boards/tcm-bf518.c
index f271310..6eebee4 100644
--- a/arch/blackfin/mach-bf518/boards/tcm-bf518.c
+++ b/arch/blackfin/mach-bf518/boards/tcm-bf518.c
@@ -730,9 +730,8 @@ void native_machine_restart(char *cmd)
 		bfin_reset_boot_spi_cs(P_DEFAULT_BOOT_SPI_CS);
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
-	random_ether_addr(addr);
-	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
+	return 1;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf527/boards/ad7160eval.c b/arch/blackfin/mach-bf527/boards/ad7160eval.c
index c8d5d2b..fad7fea 100644
--- a/arch/blackfin/mach-bf527/boards/ad7160eval.c
+++ b/arch/blackfin/mach-bf527/boards/ad7160eval.c
@@ -846,7 +846,7 @@ void native_machine_restart(char *cmd)
 		bfin_reset_boot_spi_cs(P_DEFAULT_BOOT_SPI_CS);
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	/* the MAC is stored in OTP memory page 0xDF */
 	u32 ret;
@@ -859,5 +859,6 @@ void bfin_get_ether_addr(char *addr)
 		for (ret = 0; ret < 6; ++ret)
 			addr[ret] = otp_mac_p[5 - ret];
 	}
+	return 0;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf527/boards/cm_bf527.c b/arch/blackfin/mach-bf527/boards/cm_bf527.c
index 7330607..65b7fbd 100644
--- a/arch/blackfin/mach-bf527/boards/cm_bf527.c
+++ b/arch/blackfin/mach-bf527/boards/cm_bf527.c
@@ -983,9 +983,8 @@ void native_machine_restart(char *cmd)
 		bfin_reset_boot_spi_cs(P_DEFAULT_BOOT_SPI_CS);
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
-	random_ether_addr(addr);
-	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
+	return 1;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf527/boards/ezbrd.c b/arch/blackfin/mach-bf527/boards/ezbrd.c
index db3ecfc..17c6a24 100644
--- a/arch/blackfin/mach-bf527/boards/ezbrd.c
+++ b/arch/blackfin/mach-bf527/boards/ezbrd.c
@@ -870,7 +870,7 @@ void native_machine_restart(char *cmd)
 		bfin_reset_boot_spi_cs(P_DEFAULT_BOOT_SPI_CS);
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	/* the MAC is stored in OTP memory page 0xDF */
 	u32 ret;
@@ -883,5 +883,6 @@ void bfin_get_ether_addr(char *addr)
 		for (ret = 0; ret < 6; ++ret)
 			addr[ret] = otp_mac_p[5 - ret];
 	}
+	return 0;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf527/boards/ezkit.c b/arch/blackfin/mach-bf527/boards/ezkit.c
index dfdd8e6..2f9a2bd 100644
--- a/arch/blackfin/mach-bf527/boards/ezkit.c
+++ b/arch/blackfin/mach-bf527/boards/ezkit.c
@@ -1311,7 +1311,7 @@ void native_machine_restart(char *cmd)
 		bfin_reset_boot_spi_cs(P_DEFAULT_BOOT_SPI_CS);
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	/* the MAC is stored in OTP memory page 0xDF */
 	u32 ret;
@@ -1324,5 +1324,6 @@ void bfin_get_ether_addr(char *addr)
 		for (ret = 0; ret < 6; ++ret)
 			addr[ret] = otp_mac_p[5 - ret];
 	}
+	return 0;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf527/boards/tll6527m.c b/arch/blackfin/mach-bf527/boards/tll6527m.c
index 360e97f..d192c0a 100644
--- a/arch/blackfin/mach-bf527/boards/tll6527m.c
+++ b/arch/blackfin/mach-bf527/boards/tll6527m.c
@@ -931,7 +931,7 @@ void native_machine_restart(char *cmd)
 		bfin_reset_boot_spi_cs(P_DEFAULT_BOOT_SPI_CS);
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	/* the MAC is stored in OTP memory page 0xDF */
 	u32 ret;
@@ -945,5 +945,6 @@ void bfin_get_ether_addr(char *addr)
 		for (ret = 0; ret < 6; ++ret)
 			addr[ret] = otp_mac_p[5 - ret];
 	}
+	return 0;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf537/boards/cm_bf537e.c b/arch/blackfin/mach-bf537/boards/cm_bf537e.c
index 0d4a2f6..27fd2c3 100644
--- a/arch/blackfin/mach-bf537/boards/cm_bf537e.c
+++ b/arch/blackfin/mach-bf537/boards/cm_bf537e.c
@@ -813,9 +813,8 @@ void __init native_machine_early_platform_add_devices(void)
 		ARRAY_SIZE(cm_bf537e_early_devices));
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
-	random_ether_addr(addr);
-	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
+	return 1;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf537/boards/cm_bf537u.c b/arch/blackfin/mach-bf537/boards/cm_bf537u.c
index f553698..3f3abad 100644
--- a/arch/blackfin/mach-bf537/boards/cm_bf537u.c
+++ b/arch/blackfin/mach-bf537/boards/cm_bf537u.c
@@ -790,9 +790,8 @@ void __init native_machine_early_platform_add_devices(void)
 		ARRAY_SIZE(cm_bf537u_early_devices));
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
-	random_ether_addr(addr);
-	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
+	return 1;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf537/boards/dnp5370.c b/arch/blackfin/mach-bf537/boards/dnp5370.c
index 11dadeb..6f77bf7 100644
--- a/arch/blackfin/mach-bf537/boards/dnp5370.c
+++ b/arch/blackfin/mach-bf537/boards/dnp5370.c
@@ -399,9 +399,10 @@ arch_initcall(dnp5370_init);
 /*
  * Currently the MAC address is saved in Flash by U-Boot
  */
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	*(u32 *)(&(addr[0])) = bfin_read32(FLASH_MAC);
 	*(u16 *)(&(addr[4])) = bfin_read16(FLASH_MAC + 4);
+	return 0;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf537/boards/pnav10.c b/arch/blackfin/mach-bf537/boards/pnav10.c
index 6fd8470..e9507fe 100644
--- a/arch/blackfin/mach-bf537/boards/pnav10.c
+++ b/arch/blackfin/mach-bf537/boards/pnav10.c
@@ -535,9 +535,8 @@ void __init native_machine_early_platform_add_devices(void)
 		ARRAY_SIZE(stamp_early_devices));
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
-	random_ether_addr(addr);
-	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
+	return 1;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf537/boards/stamp.c b/arch/blackfin/mach-bf537/boards/stamp.c
index 2221173..0b80725 100644
--- a/arch/blackfin/mach-bf537/boards/stamp.c
+++ b/arch/blackfin/mach-bf537/boards/stamp.c
@@ -2993,9 +2993,10 @@ void native_machine_restart(char *cmd)
  * Currently the MAC address is saved in Flash by U-Boot
  */
 #define FLASH_MAC	0x203f0000
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	*(u32 *)(&(addr[0])) = bfin_read32(FLASH_MAC);
 	*(u16 *)(&(addr[4])) = bfin_read16(FLASH_MAC + 4);
+	return 0;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf537/boards/tcm_bf537.c b/arch/blackfin/mach-bf537/boards/tcm_bf537.c
index 9885176..3fb4218 100644
--- a/arch/blackfin/mach-bf537/boards/tcm_bf537.c
+++ b/arch/blackfin/mach-bf537/boards/tcm_bf537.c
@@ -780,9 +780,8 @@ void __init native_machine_early_platform_add_devices(void)
 		ARRAY_SIZE(cm_bf537_early_devices));
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
-	random_ether_addr(addr);
-	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
+	return 1;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
-- 
1.7.8.3
