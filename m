From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 04/50] adi/blackfin: set addr_assign_type correctly if random
Date: Wed,  8 Feb 2012 22:10:11 +0100
Message-ID: <1328735457-29986-5-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Mike Frysinger <vapier@gentoo.org>,
	Bob Liu <lliubbo@gmail.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Lars-Peter Clausen <lars@metafoo.de>,
	Scott Jiang <scott.jiang@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set the addr_assign_type for adi driver correctly to
NET_ADDR_RANDOM if a random MAC address was generated.
Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 arch/blackfin/mach-bf518/boards/ezbrd.c      |    3 ++-
 arch/blackfin/mach-bf518/boards/tcm-bf518.c  |    3 ++-
 arch/blackfin/mach-bf527/boards/ad7160eval.c |    3 ++-
 arch/blackfin/mach-bf527/boards/cm_bf527.c   |    3 ++-
 arch/blackfin/mach-bf527/boards/ezbrd.c      |    3 ++-
 arch/blackfin/mach-bf527/boards/ezkit.c      |    3 ++-
 arch/blackfin/mach-bf527/boards/tll6527m.c   |    3 ++-
 arch/blackfin/mach-bf537/boards/cm_bf537e.c  |    3 ++-
 arch/blackfin/mach-bf537/boards/cm_bf537u.c  |    3 ++-
 arch/blackfin/mach-bf537/boards/dnp5370.c    |    3 ++-
 arch/blackfin/mach-bf537/boards/pnav10.c     |    3 ++-
 arch/blackfin/mach-bf537/boards/stamp.c      |    3 ++-
 arch/blackfin/mach-bf537/boards/tcm_bf537.c  |    3 ++-
 drivers/net/ethernet/adi/bfin_mac.c          |   10 +++++++---
 drivers/net/ethernet/adi/bfin_mac.h          |    2 +-
 15 files changed, 34 insertions(+), 17 deletions(-)

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
index f271310..d3c763e 100644
--- a/arch/blackfin/mach-bf518/boards/tcm-bf518.c
+++ b/arch/blackfin/mach-bf518/boards/tcm-bf518.c
@@ -730,9 +730,10 @@ void native_machine_restart(char *cmd)
 		bfin_reset_boot_spi_cs(P_DEFAULT_BOOT_SPI_CS);
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	random_ether_addr(addr);
 	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
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
index 7330607..5fb09ad 100644
--- a/arch/blackfin/mach-bf527/boards/cm_bf527.c
+++ b/arch/blackfin/mach-bf527/boards/cm_bf527.c
@@ -983,9 +983,10 @@ void native_machine_restart(char *cmd)
 		bfin_reset_boot_spi_cs(P_DEFAULT_BOOT_SPI_CS);
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	random_ether_addr(addr);
 	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
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
index dfdd8e6..89b0f6c 100644
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
index 0d4a2f6..618fd7d 100644
--- a/arch/blackfin/mach-bf537/boards/cm_bf537e.c
+++ b/arch/blackfin/mach-bf537/boards/cm_bf537e.c
@@ -813,9 +813,10 @@ void __init native_machine_early_platform_add_devices(void)
 		ARRAY_SIZE(cm_bf537e_early_devices));
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	random_ether_addr(addr);
 	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
+	return 1;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/arch/blackfin/mach-bf537/boards/cm_bf537u.c b/arch/blackfin/mach-bf537/boards/cm_bf537u.c
index f553698..48a7a23 100644
--- a/arch/blackfin/mach-bf537/boards/cm_bf537u.c
+++ b/arch/blackfin/mach-bf537/boards/cm_bf537u.c
@@ -790,9 +790,10 @@ void __init native_machine_early_platform_add_devices(void)
 		ARRAY_SIZE(cm_bf537u_early_devices));
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	random_ether_addr(addr);
 	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
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
index 6fd8470..2a9cd61 100644
--- a/arch/blackfin/mach-bf537/boards/pnav10.c
+++ b/arch/blackfin/mach-bf537/boards/pnav10.c
@@ -535,9 +535,10 @@ void __init native_machine_early_platform_add_devices(void)
 		ARRAY_SIZE(stamp_early_devices));
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	random_ether_addr(addr);
 	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
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
index 9885176..02eb9d0 100644
--- a/arch/blackfin/mach-bf537/boards/tcm_bf537.c
+++ b/arch/blackfin/mach-bf537/boards/tcm_bf537.c
@@ -780,9 +780,10 @@ void __init native_machine_early_platform_add_devices(void)
 		ARRAY_SIZE(cm_bf537_early_devices));
 }
 
-void bfin_get_ether_addr(char *addr)
+int bfin_get_ether_addr(char *addr)
 {
 	random_ether_addr(addr);
 	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n", __FILE__, __func__);
+	return 1;
 }
 EXPORT_SYMBOL(bfin_get_ether_addr);
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index d812a10..064a3a6 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -621,6 +621,8 @@ static int bfin_mac_set_mac_address(struct net_device *dev, void *p)
 	if (netif_running(dev))
 		return -EBUSY;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	if (dev->addr_assign_type & NET_ADDR_RANDOM)
+		dev->addr_assign_type ^= NET_ADDR_RANDOM;
 	setup_mac_addr(dev->dev_addr);
 	return 0;
 }
@@ -1496,12 +1498,14 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	 * Grab the MAC from the board somehow
 	 * this is done in the arch/blackfin/mach-bfxxx/boards/eth_mac.c
 	 */
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		bfin_get_ether_addr(ndev->dev_addr);
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		if (bfin_get_ether_addr(ndev->dev_addr))
+			ndev->addr_assign_type |= NET_ADDR_RANDOM;
+	}
 
 	/* If still not valid, get a random one */
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		random_ether_addr(ndev->dev_addr);
+		dev_hw_addr_random(ndev, ndev->dev_addr);
 
 	setup_mac_addr(ndev->dev_addr);
 
diff --git a/drivers/net/ethernet/adi/bfin_mac.h b/drivers/net/ethernet/adi/bfin_mac.h
index f8559ac..960905c 100644
--- a/drivers/net/ethernet/adi/bfin_mac.h
+++ b/drivers/net/ethernet/adi/bfin_mac.h
@@ -101,6 +101,6 @@ struct bfin_mac_local {
 #endif
 };
 
-extern void bfin_get_ether_addr(char *addr);
+extern int bfin_get_ether_addr(char *addr);
 
 #endif
-- 
1.7.7.3
