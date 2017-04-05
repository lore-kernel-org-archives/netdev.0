From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] format-security: move static strings to const
Date: Wed, 5 Apr 2017 14:47:11 -0700
Message-ID: <20170405214711.GA5711@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tony Lindgren <tony@atomide.com>,
        Russell King <linux@armlinux.org.uk>,
        "Maciej W. Rozycki" <macro@linux-mips.org>,
        Ralf Baechle <ralf@linux-mips.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Viresh Kumar <viresh.kumar@linaro.org>,
        Daniel Vetter <daniel.vetter@intel.com>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        Sean Paul <seanpaul@chromium.org>,
        David Airlie <airlied@linux.ie>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
        Jes Sorensen <jes@trained-monkey.org>,
        Jiri Slaby <jslaby@suse.com>,
        Patrice Chotard <patrice.chotard@st.com>,
        "David S. Miller" <davem@davemloft.net>,
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

While examining output from trial builds with -Wformat-security enabled,
many strings were found that should be defined as "const", or as a char
array instead of char pointer. This makes some static analysis easier,
by producing fewer false positives.

As these are all trivial changes, it seemed best to put them all in
a single patch rather than chopping them up per maintainer.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/arm/mach-omap2/board-n8x0.c                  |  2 +-
 arch/mips/dec/prom/init.c                         |  6 +++---
 arch/mips/kernel/traps.c                          |  4 ++--
 drivers/char/dsp56k.c                             |  2 +-
 drivers/cpufreq/powernow-k8.c                     |  3 ++-
 drivers/gpu/drm/drm_fb_helper.c                   |  2 +-
 drivers/net/ethernet/amd/atarilance.c             |  4 ++--
 drivers/net/ethernet/amd/declance.c               |  2 +-
 drivers/net/ethernet/amd/sun3lance.c              |  3 ++-
 drivers/net/ethernet/cirrus/mac89x0.c             |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h |  2 +-
 drivers/net/ethernet/natsemi/sonic.h              |  2 +-
 drivers/net/ethernet/toshiba/tc35815.c            |  2 +-
 drivers/net/fddi/defxx.c                          |  2 +-
 drivers/net/hippi/rrunner.c                       |  3 ++-
 drivers/staging/most/mostcore/core.c              |  2 +-
 drivers/tty/n_hdlc.c                              | 10 +++++-----
 drivers/tty/serial/st-asc.c                       |  2 +-
 net/decnet/af_decnet.c                            |  3 ++-
 19 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/arch/arm/mach-omap2/board-n8x0.c b/arch/arm/mach-omap2/board-n8x0.c
index 6b6fda65fb3b..91272db09fa3 100644
--- a/arch/arm/mach-omap2/board-n8x0.c
+++ b/arch/arm/mach-omap2/board-n8x0.c
@@ -117,7 +117,7 @@ static struct musb_hdrc_platform_data tusb_data = {
 static void __init n8x0_usb_init(void)
 {
 	int ret = 0;
-	static char	announce[] __initdata = KERN_INFO "TUSB 6010\n";
+	static const char announce[] __initconst = KERN_INFO "TUSB 6010\n";
 
 	/* PM companion chip power control pin */
 	ret = gpio_request_one(TUSB6010_GPIO_ENABLE, GPIOF_OUT_INIT_LOW,
diff --git a/arch/mips/dec/prom/init.c b/arch/mips/dec/prom/init.c
index 4e1761e0a09a..d88eb7a6662b 100644
--- a/arch/mips/dec/prom/init.c
+++ b/arch/mips/dec/prom/init.c
@@ -88,7 +88,7 @@ void __init which_prom(s32 magic, s32 *prom_vec)
 void __init prom_init(void)
 {
 	extern void dec_machine_halt(void);
-	static char cpu_msg[] __initdata =
+	static const char cpu_msg[] __initconst =
 		"Sorry, this kernel is compiled for a wrong CPU type!\n";
 	s32 argc = fw_arg0;
 	s32 *argv = (void *)fw_arg1;
@@ -111,7 +111,7 @@ void __init prom_init(void)
 #if defined(CONFIG_CPU_R3000)
 	if ((current_cpu_type() == CPU_R4000SC) ||
 	    (current_cpu_type() == CPU_R4400SC)) {
-		static char r4k_msg[] __initdata =
+		static const char r4k_msg[] __initconst =
 			"Please recompile with \"CONFIG_CPU_R4x00 = y\".\n";
 		printk(cpu_msg);
 		printk(r4k_msg);
@@ -122,7 +122,7 @@ void __init prom_init(void)
 #if defined(CONFIG_CPU_R4X00)
 	if ((current_cpu_type() == CPU_R3000) ||
 	    (current_cpu_type() == CPU_R3000A)) {
-		static char r3k_msg[] __initdata =
+		static const char r3k_msg[] __initconst =
 			"Please recompile with \"CONFIG_CPU_R3000 = y\".\n";
 		printk(cpu_msg);
 		printk(r3k_msg);
diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index c7d17cfb32f6..2c717db50380 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -2256,8 +2256,8 @@ void set_handler(unsigned long offset, void *addr, unsigned long size)
 	local_flush_icache_range(ebase + offset, ebase + offset + size);
 }
 
-static char panic_null_cerr[] =
-	"Trying to set NULL cache error exception handler";
+static const char panic_null_cerr[] =
+	"Trying to set NULL cache error exception handler\n";
 
 /*
  * Install uncached CPU exception handler.
diff --git a/drivers/char/dsp56k.c b/drivers/char/dsp56k.c
index 50aa9ba91f25..0d7b577e0ff0 100644
--- a/drivers/char/dsp56k.c
+++ b/drivers/char/dsp56k.c
@@ -489,7 +489,7 @@ static const struct file_operations dsp56k_fops = {
 
 /****** Init and module functions ******/
 
-static char banner[] __initdata = KERN_INFO "DSP56k driver installed\n";
+static const char banner[] __initconst = KERN_INFO "DSP56k driver installed\n";
 
 static int __init dsp56k_init_driver(void)
 {
diff --git a/drivers/cpufreq/powernow-k8.c b/drivers/cpufreq/powernow-k8.c
index 0b5bf135b090..062d71434e47 100644
--- a/drivers/cpufreq/powernow-k8.c
+++ b/drivers/cpufreq/powernow-k8.c
@@ -1171,7 +1171,8 @@ static struct cpufreq_driver cpufreq_amd64_driver = {
 
 static void __request_acpi_cpufreq(void)
 {
-	const char *cur_drv, *drv = "acpi-cpufreq";
+	const char drv[] = "acpi-cpufreq";
+	const char *cur_drv;
 
 	cur_drv = cpufreq_get_current_driver();
 	if (!cur_drv)
diff --git a/drivers/gpu/drm/drm_fb_helper.c b/drivers/gpu/drm/drm_fb_helper.c
index f6d4d9700734..1ff9d5912b83 100644
--- a/drivers/gpu/drm/drm_fb_helper.c
+++ b/drivers/gpu/drm/drm_fb_helper.c
@@ -2331,7 +2331,7 @@ EXPORT_SYMBOL(drm_fb_helper_hotplug_event);
 int __init drm_fb_helper_modinit(void)
 {
 #if defined(CONFIG_FRAMEBUFFER_CONSOLE_MODULE) && !defined(CONFIG_EXPERT)
-	const char *name = "fbcon";
+	const char name[] = "fbcon";
 	struct module *fbcon;
 
 	mutex_lock(&module_mutex);
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index 796c37a5bbde..c5b81268c284 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -42,8 +42,8 @@
 
 */
 
-static char version[] = "atarilance.c: v1.3 04/04/96 "
-					   "Roman.Hodek@informatik.uni-erlangen.de\n";
+static const char version[] = "atarilance.c: v1.3 04/04/96 "
+			      "Roman.Hodek@informatik.uni-erlangen.de\n";
 
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index 6c98901f1b89..82cc81385033 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -72,7 +72,7 @@
 #include <asm/dec/machtype.h>
 #include <asm/dec/system.h>
 
-static char version[] =
+static const char version[] =
 "declance.c: v0.011 by Linux MIPS DECstation task force\n";
 
 MODULE_AUTHOR("Linux MIPS DECstation task force");
diff --git a/drivers/net/ethernet/amd/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
index 12bb4f1489fc..77b1db267730 100644
--- a/drivers/net/ethernet/amd/sun3lance.c
+++ b/drivers/net/ethernet/amd/sun3lance.c
@@ -21,7 +21,8 @@
 
 */
 
-static char *version = "sun3lance.c: v1.2 1/12/2001  Sam Creasey (sammy@sammy.net)\n";
+static const char version[] =
+"sun3lance.c: v1.2 1/12/2001  Sam Creasey (sammy@sammy.net)\n";
 
 #include <linux/module.h>
 #include <linux/stddef.h>
diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/ethernet/cirrus/mac89x0.c
index b600fbbbf679..f910f0f386d6 100644
--- a/drivers/net/ethernet/cirrus/mac89x0.c
+++ b/drivers/net/ethernet/cirrus/mac89x0.c
@@ -56,7 +56,7 @@
   local_irq_{dis,en}able()
 */
 
-static char *version =
+static const char version[] =
 "cs89x0.c:v1.02 11/26/96 Russell Nelson <nelson@crynwr.com>\n";
 
 /* ======================= configure the driver here ======================= */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 2bb3d1e93c64..1951b65c7a57 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -407,7 +407,7 @@ struct mac_driver {
 };
 
 struct mac_stats_string {
-	char desc[ETH_GSTRING_LEN];
+	const char desc[ETH_GSTRING_LEN];
 	unsigned long offset;
 };
 
diff --git a/drivers/net/ethernet/natsemi/sonic.h b/drivers/net/ethernet/natsemi/sonic.h
index 07091dd27e5d..7b0a8db57af9 100644
--- a/drivers/net/ethernet/natsemi/sonic.h
+++ b/drivers/net/ethernet/natsemi/sonic.h
@@ -444,7 +444,7 @@ static inline __u16 sonic_rra_get(struct net_device* dev, int entry,
 			     (entry * SIZEOF_SONIC_RR) + offset);
 }
 
-static const char *version =
+static const char version[] =
     "sonic.c:v0.92 20.9.98 tsbogend@alpha.franken.de\n";
 
 #endif /* SONIC_H */
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index a45f98fa4aa7..ad6db05b97d6 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -23,7 +23,7 @@
  */
 
 #define DRV_VERSION	"1.39"
-static const char *version = "tc35815.c:v" DRV_VERSION "\n";
+static const char version[] = "tc35815.c:v" DRV_VERSION "\n";
 #define MODNAME			"tc35815"
 
 #include <linux/module.h>
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index b0de8ecd7fe8..f4a816cf012a 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -228,7 +228,7 @@
 #define DRV_VERSION "v1.11"
 #define DRV_RELDATE "2014/07/01"
 
-static char version[] =
+static const char version[] =
 	DRV_NAME ": " DRV_VERSION " " DRV_RELDATE
 	"  Lawrence V. Stefani and others\n";
 
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index dd7fc6659ad4..9b0d6148e994 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -60,7 +60,8 @@ MODULE_AUTHOR("Jes Sorensen <jes@wildopensource.com>");
 MODULE_DESCRIPTION("Essential RoadRunner HIPPI driver");
 MODULE_LICENSE("GPL");
 
-static char version[] = "rrunner.c: v0.50 11/11/2002  Jes Sorensen (jes@wildopensource.com)\n";
+static const char version[] =
+"rrunner.c: v0.50 11/11/2002  Jes Sorensen (jes@wildopensource.com)\n";
 
 
 static const struct net_device_ops rr_netdev_ops = {
diff --git a/drivers/staging/most/mostcore/core.c b/drivers/staging/most/mostcore/core.c
index 191404bc5906..892aae6e9c9a 100644
--- a/drivers/staging/most/mostcore/core.c
+++ b/drivers/staging/most/mostcore/core.c
@@ -82,7 +82,7 @@ struct most_inst_obj {
 
 static const struct {
 	int most_ch_data_type;
-	char *name;
+	const char *name;
 } ch_data_type[] = {
 	{ MOST_CH_CONTROL, "control\n" },
 	{ MOST_CH_ASYNC, "async\n" },
diff --git a/drivers/tty/n_hdlc.c b/drivers/tty/n_hdlc.c
index e94aea8c0d05..7b2a466616d6 100644
--- a/drivers/tty/n_hdlc.c
+++ b/drivers/tty/n_hdlc.c
@@ -939,11 +939,11 @@ static struct n_hdlc_buf *n_hdlc_buf_get(struct n_hdlc_buf_list *buf_list)
 	return buf;
 }	/* end of n_hdlc_buf_get() */
 
-static char hdlc_banner[] __initdata =
+static const char hdlc_banner[] __initconst =
 	KERN_INFO "HDLC line discipline maxframe=%u\n";
-static char hdlc_register_ok[] __initdata =
+static const char hdlc_register_ok[] __initconst =
 	KERN_INFO "N_HDLC line discipline registered.\n";
-static char hdlc_register_fail[] __initdata =
+static const char hdlc_register_fail[] __initconst =
 	KERN_ERR "error registering line discipline: %d\n";
 
 static int __init n_hdlc_init(void)
@@ -968,9 +968,9 @@ static int __init n_hdlc_init(void)
 	
 }	/* end of init_module() */
 
-static char hdlc_unregister_ok[] __exitdata =
+static const char hdlc_unregister_ok[] __exitdata =
 	KERN_INFO "N_HDLC: line discipline unregistered\n";
-static char hdlc_unregister_fail[] __exitdata =
+static const char hdlc_unregister_fail[] __exitdata =
 	KERN_ERR "N_HDLC: can't unregister line discipline (err = %d)\n";
 
 static void __exit n_hdlc_exit(void)
diff --git a/drivers/tty/serial/st-asc.c b/drivers/tty/serial/st-asc.c
index bcf1d33e6ffe..ef9f47847f59 100644
--- a/drivers/tty/serial/st-asc.c
+++ b/drivers/tty/serial/st-asc.c
@@ -985,7 +985,7 @@ static struct platform_driver asc_serial_driver = {
 static int __init asc_init(void)
 {
 	int ret;
-	static char banner[] __initdata =
+	static const char banner[] __initconst =
 		KERN_INFO "STMicroelectronics ASC driver initialized\n";
 
 	printk(banner);
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index e6e79eda9763..c6ed5e9502e9 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2359,7 +2359,8 @@ MODULE_AUTHOR("Linux DECnet Project Team");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_NETPROTO(PF_DECnet);
 
-static char banner[] __initdata = KERN_INFO "NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team\n";
+static const char banner[] __initconst = KERN_INFO
+"NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team\n";
 
 static int __init decnet_init(void)
 {
-- 
2.7.4


-- 
Kees Cook
Pixel Security
