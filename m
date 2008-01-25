From: Jochen Friedrich <jochen@scram.de>
Subject: [PATCH for-2.6.25] [POWERPC] Rename commproc to cpm1 and cpm2_common.c
 to cpm2.c
Date: Fri, 25 Jan 2008 15:31:42 +0100
Message-ID: <4799F2CE.309@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Garzik, Jeff" <jgarzik@pobox.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Scott Wood <scottwood@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kernel, Linux" <linux-kernel@vger.kernel.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757708AbYAYOcT@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename commproc.[ch] to cpm1.[ch] to be more consistent with cpm2. Also
rename cpm2_common.c to cpm2.c as suggested by Scott Wood. Adjust the
includes accordingly.

Signed-off-by: Jochen Friedrich <jochen@scram.de>
---
 arch/powerpc/platforms/8xx/ep88xc.c           |    1 +
 arch/powerpc/platforms/8xx/mpc86xads_setup.c  |    2 +-
 arch/powerpc/platforms/8xx/mpc885ads_setup.c  |    2 +-
 arch/powerpc/sysdev/Makefile                  |    4 ++--
 arch/powerpc/sysdev/{commproc.c => cpm1.c}    |    4 ++--
 arch/powerpc/sysdev/{cpm2_common.c => cpm2.c} |    3 +--
 arch/powerpc/sysdev/micropatch.c              |    2 +-
 arch/ppc/8260_io/enet.c                       |    2 +-
 arch/ppc/8xx_io/commproc.c                    |    2 +-
 arch/ppc/8xx_io/enet.c                        |    6 +++---
 arch/ppc/8xx_io/fec.c                         |    2 +-
 arch/ppc/8xx_io/micropatch.c                  |    2 +-
 arch/ppc/boot/simple/iic.c                    |    2 +-
 arch/ppc/boot/simple/m8xx_tty.c               |    2 +-
 arch/ppc/kernel/ppc_ksyms.c                   |    2 +-
 arch/ppc/platforms/mpc866ads_setup.c          |    2 +-
 arch/ppc/platforms/mpc885ads_setup.c          |    2 +-
 arch/ppc/syslib/mpc8xx_devices.c              |    2 +-
 arch/ppc/xmon/start_8xx.c                     |    2 +-
 drivers/net/fec_8xx/fec_8xx-netta.c           |    2 +-
 drivers/net/fec_8xx/fec_main.c                |    2 +-
 drivers/net/fec_8xx/fec_mii.c                 |    2 +-
 drivers/net/fs_enet/fs_enet.h                 |    2 +-
 drivers/net/fs_enet/mac-fec.c                 |    2 +-
 drivers/net/fs_enet/mac-scc.c                 |    2 +-
 drivers/serial/cpm_uart/cpm_uart_cpm1.h       |    2 +-
 include/asm-powerpc/{commproc.h => cpm1.h}    |    8 ++++----
 include/asm-ppc/{commproc.h => cpm1.h}        |    8 ++++----
 28 files changed, 38 insertions(+), 38 deletions(-)
 rename arch/powerpc/sysdev/{commproc.c => cpm1.c} (99%)
 rename arch/powerpc/sysdev/{cpm2_common.c => cpm2.c} (99%)
 rename include/asm-powerpc/{commproc.h => cpm1.h} (99%)
 rename include/asm-ppc/{commproc.h => cpm1.h} (99%)

diff --git a/arch/powerpc/platforms/8xx/ep88xc.c b/arch/powerpc/platforms/8xx/ep88xc.c
index 4897eda..a8dffa0 100644
--- a/arch/powerpc/platforms/8xx/ep88xc.c
+++ b/arch/powerpc/platforms/8xx/ep88xc.c
@@ -16,6 +16,7 @@
 #include <asm/io.h>
 #include <asm/udbg.h>
 #include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 #include "mpc8xx.h"
 
diff --git a/arch/powerpc/platforms/8xx/mpc86xads_setup.c b/arch/powerpc/platforms/8xx/mpc86xads_setup.c
index c0dda53..c028a5b 100644
--- a/arch/powerpc/platforms/8xx/mpc86xads_setup.c
+++ b/arch/powerpc/platforms/8xx/mpc86xads_setup.c
@@ -22,7 +22,7 @@
 #include <asm/system.h>
 #include <asm/time.h>
 #include <asm/8xx_immap.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #include <asm/fs_pd.h>
 #include <asm/udbg.h>
 
diff --git a/arch/powerpc/platforms/8xx/mpc885ads_setup.c b/arch/powerpc/platforms/8xx/mpc885ads_setup.c
index 3be115e..6e7ded0 100644
--- a/arch/powerpc/platforms/8xx/mpc885ads_setup.c
+++ b/arch/powerpc/platforms/8xx/mpc885ads_setup.c
@@ -36,7 +36,7 @@
 #include <asm/time.h>
 #include <asm/mpc8xx.h>
 #include <asm/8xx_immap.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #include <asm/fs_pd.h>
 #include <asm/udbg.h>
 
diff --git a/arch/powerpc/sysdev/Makefile b/arch/powerpc/sysdev/Makefile
index f17e7b8..928d75b 100644
--- a/arch/powerpc/sysdev/Makefile
+++ b/arch/powerpc/sysdev/Makefile
@@ -36,8 +36,8 @@ endif
 # Temporary hack until we have migrated to asm-powerpc
 ifeq ($(ARCH),powerpc)
 obj-$(CONFIG_CPM)		+= cpm_common.o
-obj-$(CONFIG_CPM2)		+= cpm2_common.o cpm2_pic.o
+obj-$(CONFIG_CPM2)		+= cpm2.o cpm2_pic.o
 obj-$(CONFIG_PPC_DCR)		+= dcr.o
-obj-$(CONFIG_8xx)		+= mpc8xx_pic.o commproc.o
+obj-$(CONFIG_8xx)		+= mpc8xx_pic.o cpm1.o
 obj-$(CONFIG_UCODE_PATCH)	+= micropatch.o
 endif
diff --git a/arch/powerpc/sysdev/commproc.c b/arch/powerpc/sysdev/cpm1.c
similarity index 99%
rename from arch/powerpc/sysdev/commproc.c
rename to arch/powerpc/sysdev/cpm1.c
index ef82587..df8bd2b 100644
--- a/arch/powerpc/sysdev/commproc.c
+++ b/arch/powerpc/sysdev/cpm1.c
@@ -33,7 +33,7 @@
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/8xx_immap.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #include <asm/io.h>
 #include <asm/tlbflush.h>
 #include <asm/rheap.h>
@@ -290,7 +290,7 @@ cpm_setbrg(uint brg, uint rate)
 		out_be32(bp, (((BRG_UART_CLK / rate) - 1) << 1) | CPM_BRG_EN);
 	else
 		out_be32(bp, (((BRG_UART_CLK_DIV16 / rate) - 1) << 1) |
-		             CPM_BRG_EN | CPM_BRG_DIV16);
+			      CPM_BRG_EN | CPM_BRG_DIV16);
 }
 
 #ifndef CONFIG_PPC_CPM_NEW_BINDING
diff --git a/arch/powerpc/sysdev/cpm2_common.c b/arch/powerpc/sysdev/cpm2.c
similarity index 99%
rename from arch/powerpc/sysdev/cpm2_common.c
rename to arch/powerpc/sysdev/cpm2.c
index f7188e2..7be7112 100644
--- a/arch/powerpc/sysdev/cpm2_common.c
+++ b/arch/powerpc/sysdev/cpm2.c
@@ -153,8 +153,7 @@ cpm2_fastbrg(uint brg, uint rate, int div16)
 
 	if (brg < 4) {
 		bp = cpm2_map_size(im_brgc1, 16);
-	}
-	else {
+	} else {
 		bp = cpm2_map_size(im_brgc5, 16);
 		brg -= 4;
 	}
diff --git a/arch/powerpc/sysdev/micropatch.c b/arch/powerpc/sysdev/micropatch.c
index 712b10a..d8d6028 100644
--- a/arch/powerpc/sysdev/micropatch.c
+++ b/arch/powerpc/sysdev/micropatch.c
@@ -16,7 +16,7 @@
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/8xx_immap.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 /*
  * I2C/SPI relocation patch arrays.
diff --git a/arch/ppc/8260_io/enet.c b/arch/ppc/8260_io/enet.c
index 615b658..3ea4db2 100644
--- a/arch/ppc/8260_io/enet.c
+++ b/arch/ppc/8260_io/enet.c
@@ -10,7 +10,7 @@
  * This version of the driver is somewhat selectable for the different
  * processor/board combinations.  It works for the boards I know about
  * now, and should be easily modified to include others.  Some of the
- * configuration information is contained in <asm/commproc.h> and the
+ * configuration information is contained in <asm/cpm1.h> and the
  * remainder is here.
  *
  * Buffer descriptors are kept in the CPM dual port RAM, and the frame
diff --git a/arch/ppc/8xx_io/commproc.c b/arch/ppc/8xx_io/commproc.c
index 3f93af8..9d656de 100644
--- a/arch/ppc/8xx_io/commproc.c
+++ b/arch/ppc/8xx_io/commproc.c
@@ -34,7 +34,7 @@
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/8xx_immap.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #include <asm/io.h>
 #include <asm/tlbflush.h>
 #include <asm/rheap.h>
diff --git a/arch/ppc/8xx_io/enet.c b/arch/ppc/8xx_io/enet.c
index eace3bc..c6d047a 100644
--- a/arch/ppc/8xx_io/enet.c
+++ b/arch/ppc/8xx_io/enet.c
@@ -8,7 +8,7 @@
  * This version of the driver is somewhat selectable for the different
  * processor/board combinations.  It works for the boards I know about
  * now, and should be easily modified to include others.  Some of the
- * configuration information is contained in <asm/commproc.h> and the
+ * configuration information is contained in <asm/cpm1.h> and the
  * remainder is here.
  *
  * Buffer descriptors are kept in the CPM dual port RAM, and the frame
@@ -43,7 +43,7 @@
 #include <asm/pgtable.h>
 #include <asm/mpc8xx.h>
 #include <asm/uaccess.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #include <asm/cacheflush.h>
 
 /*
@@ -80,7 +80,7 @@
  * programming documents for details unique to your board.
  *
  * For the TQM8xx(L) modules, there is no control register interface.
- * All functions are directly controlled using I/O pins.  See <asm/commproc.h>.
+ * All functions are directly controlled using I/O pins.  See <asm/cpm1.h>.
  */
 
 /* The transmitter timeout
diff --git a/arch/ppc/8xx_io/fec.c b/arch/ppc/8xx_io/fec.c
index 0288279..11b0aa6 100644
--- a/arch/ppc/8xx_io/fec.c
+++ b/arch/ppc/8xx_io/fec.c
@@ -53,7 +53,7 @@
 #include <asm/mpc8xx.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 #ifdef	CONFIG_USE_MDIO
 /* Forward declarations of some structures to support different PHYs
diff --git a/arch/ppc/8xx_io/micropatch.c b/arch/ppc/8xx_io/micropatch.c
index cfad46b..9a5d95d 100644
--- a/arch/ppc/8xx_io/micropatch.c
+++ b/arch/ppc/8xx_io/micropatch.c
@@ -16,7 +16,7 @@
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/8xx_immap.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 /*
  * I2C/SPI relocation patch arrays.
diff --git a/arch/ppc/boot/simple/iic.c b/arch/ppc/boot/simple/iic.c
index e4efd83..5e91489 100644
--- a/arch/ppc/boot/simple/iic.c
+++ b/arch/ppc/boot/simple/iic.c
@@ -5,7 +5,7 @@
 #include <linux/types.h>
 #include <asm/uaccess.h>
 #include <asm/mpc8xx.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 
 /* IIC functions.
diff --git a/arch/ppc/boot/simple/m8xx_tty.c b/arch/ppc/boot/simple/m8xx_tty.c
index ea615d8..f28924e 100644
--- a/arch/ppc/boot/simple/m8xx_tty.c
+++ b/arch/ppc/boot/simple/m8xx_tty.c
@@ -11,7 +11,7 @@
 #include <linux/types.h>
 #include <asm/uaccess.h>
 #include <asm/mpc8xx.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 #ifdef CONFIG_MBX
 #define MBX_CSR1	((volatile u_char *)0xfa100000)
diff --git a/arch/ppc/kernel/ppc_ksyms.c b/arch/ppc/kernel/ppc_ksyms.c
index 22494ec..0d53dc3 100644
--- a/arch/ppc/kernel/ppc_ksyms.c
+++ b/arch/ppc/kernel/ppc_ksyms.c
@@ -45,7 +45,7 @@
 #include <asm/dcr.h>
 
 #ifdef  CONFIG_8xx
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #endif
 
 extern void transfer_to_handler(void);
diff --git a/arch/ppc/platforms/mpc866ads_setup.c b/arch/ppc/platforms/mpc866ads_setup.c
index bf72204..62370f4 100644
--- a/arch/ppc/platforms/mpc866ads_setup.c
+++ b/arch/ppc/platforms/mpc866ads_setup.c
@@ -32,7 +32,7 @@
 #include <asm/time.h>
 #include <asm/ppcboot.h>
 #include <asm/8xx_immap.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #include <asm/ppc_sys.h>
 #include <asm/mpc8xx.h>
 
diff --git a/arch/ppc/platforms/mpc885ads_setup.c b/arch/ppc/platforms/mpc885ads_setup.c
index 87deaef..ba06cc0 100644
--- a/arch/ppc/platforms/mpc885ads_setup.c
+++ b/arch/ppc/platforms/mpc885ads_setup.c
@@ -31,7 +31,7 @@
 #include <asm/time.h>
 #include <asm/ppcboot.h>
 #include <asm/8xx_immap.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #include <asm/ppc_sys.h>
 
 extern unsigned char __res[];
diff --git a/arch/ppc/syslib/mpc8xx_devices.c b/arch/ppc/syslib/mpc8xx_devices.c
index c05ac87..80804ee 100644
--- a/arch/ppc/syslib/mpc8xx_devices.c
+++ b/arch/ppc/syslib/mpc8xx_devices.c
@@ -16,7 +16,7 @@
 #include <linux/device.h>
 #include <linux/serial_8250.h>
 #include <linux/mii.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #include <asm/mpc8xx.h>
 #include <asm/irq.h>
 #include <asm/ppc_sys.h>
diff --git a/arch/ppc/xmon/start_8xx.c b/arch/ppc/xmon/start_8xx.c
index a48bd59..3097406 100644
--- a/arch/ppc/xmon/start_8xx.c
+++ b/arch/ppc/xmon/start_8xx.c
@@ -14,7 +14,7 @@
 #include <linux/kernel.h>
 #include <asm/8xx_immap.h>
 #include <asm/mpc8xx.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 extern void xmon_printf(const char *fmt, ...);
 extern int xmon_8xx_write(char *str, int nb);
diff --git a/drivers/net/fec_8xx/fec_8xx-netta.c b/drivers/net/fec_8xx/fec_8xx-netta.c
index e492eb8..79deee2 100644
--- a/drivers/net/fec_8xx/fec_8xx-netta.c
+++ b/drivers/net/fec_8xx/fec_8xx-netta.c
@@ -26,7 +26,7 @@
 #include <asm/mpc8xx.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 #include "fec_8xx.h"
 
diff --git a/drivers/net/fec_8xx/fec_main.c b/drivers/net/fec_8xx/fec_main.c
index ab9637a..ca8d2e8 100644
--- a/drivers/net/fec_8xx/fec_main.c
+++ b/drivers/net/fec_8xx/fec_main.c
@@ -35,7 +35,7 @@
 #include <asm/mpc8xx.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 #include "fec_8xx.h"
 
diff --git a/drivers/net/fec_8xx/fec_mii.c b/drivers/net/fec_8xx/fec_mii.c
index e8e10a0..3b6ca29 100644
--- a/drivers/net/fec_8xx/fec_mii.c
+++ b/drivers/net/fec_8xx/fec_mii.c
@@ -34,7 +34,7 @@
 #include <asm/mpc8xx.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 /*************************************************/
 
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index c675e29..e05389c 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -12,7 +12,7 @@
 #include <asm/fs_pd.h>
 
 #ifdef CONFIG_CPM1
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 struct fec_info {
 	fec_t __iomem *fecp;
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index c1fee48..8a311d1 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -40,7 +40,7 @@
 #include <asm/8xx_immap.h>
 #include <asm/pgtable.h>
 #include <asm/mpc8xx.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #endif
 
 #ifdef CONFIG_PPC_CPM_NEW_BINDING
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index fe3d8a6..d7ca319 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -40,7 +40,7 @@
 #include <asm/8xx_immap.h>
 #include <asm/pgtable.h>
 #include <asm/mpc8xx.h>
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 #endif
 
 #ifdef CONFIG_PPC_CPM_NEW_BINDING
diff --git a/drivers/serial/cpm_uart/cpm_uart_cpm1.h b/drivers/serial/cpm_uart/cpm_uart_cpm1.h
index 9b5465f..ddf46d3 100644
--- a/drivers/serial/cpm_uart/cpm_uart_cpm1.h
+++ b/drivers/serial/cpm_uart/cpm_uart_cpm1.h
@@ -10,7 +10,7 @@
 #ifndef CPM_UART_CPM1_H
 #define CPM_UART_CPM1_H
 
-#include <asm/commproc.h>
+#include <asm/cpm1.h>
 
 /* defines for IRQs */
 #ifndef CONFIG_PPC_CPM_NEW_BINDING
diff --git a/include/asm-powerpc/commproc.h b/include/asm-powerpc/cpm1.h
similarity index 99%
rename from include/asm-powerpc/commproc.h
rename to include/asm-powerpc/cpm1.h
index ec87b8f..901a00b 100644
--- a/include/asm-powerpc/commproc.h
+++ b/include/asm-powerpc/cpm1.h
@@ -14,8 +14,8 @@
  * IDMA1 space.  The remaining DP RAM is available for buffer descriptors
  * or other use.
  */
-#ifndef __CPM_8XX__
-#define __CPM_8XX__
+#ifndef __CPM1__
+#define __CPM1__
 
 #include <asm/8xx_immap.h>
 #include <asm/ptrace.h>
@@ -82,7 +82,7 @@ extern int cpm_dpfree(unsigned long offset);
 extern unsigned long cpm_dpalloc_fixed(unsigned long offset, uint size, uint align);
 extern void cpm_dpdump(void);
 extern void *cpm_dpram_addr(unsigned long offset);
-extern uint cpm_dpram_phys(u8* addr);
+extern uint cpm_dpram_phys(u8 *addr);
 #endif
 
 extern void cpm_setbrg(uint brg, uint rate);
@@ -747,4 +747,4 @@ enum cpm_clk {
 
 int cpm1_clk_setup(enum cpm_clk_target target, int clock, int mode);
 
-#endif /* __CPM_8XX__ */
+#endif /* __CPM1__ */
diff --git a/include/asm-ppc/commproc.h b/include/asm-ppc/cpm1.h
similarity index 99%
rename from include/asm-ppc/commproc.h
rename to include/asm-ppc/cpm1.h
index 5418d6d..03035ac 100644
--- a/include/asm-ppc/commproc.h
+++ b/include/asm-ppc/cpm1.h
@@ -14,8 +14,8 @@
  * IDMA1 space.  The remaining DP RAM is available for buffer descriptors
  * or other use.
  */
-#ifndef __CPM_8XX__
-#define __CPM_8XX__
+#ifndef __CPM1__
+#define __CPM1__
 
 #include <asm/8xx_immap.h>
 #include <asm/ptrace.h>
@@ -72,7 +72,7 @@ extern int cpm_dpfree(unsigned long offset);
 extern unsigned long cpm_dpalloc_fixed(unsigned long offset, uint size, uint align);
 extern void cpm_dpdump(void);
 extern void *cpm_dpram_addr(unsigned long offset);
-extern uint cpm_dpram_phys(u8* addr);
+extern uint cpm_dpram_phys(u8 *addr);
 extern void cpm_setbrg(uint brg, uint rate);
 
 extern void cpm_load_patch(volatile immap_t *immr);
@@ -685,4 +685,4 @@ typedef struct risc_timer_pram {
 extern void cpm_install_handler(int vec, void (*handler)(void *), void *dev_id);
 extern void cpm_free_handler(int vec);
 
-#endif /* __CPM_8XX__ */
+#endif /* __CPM1__ */
-- 
1.5.3.8
