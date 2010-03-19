From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH] Cosmetic:Partially remove deprecated __initcall() and change to
Date: Fri, 19 Mar 2010 12:51:31 -0700
Message-ID: <1269028291-9103-1-git-send-email-justinmattock@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-audit@redhat.com,
	uclinux-dist-devel@blackfin.uclinux.org,
	linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org,
	linux-mips@linux-mips.org, linux-parisc@vger.kernel.org,
	linux-s390@vger.kernel.org, selinux@tycho.nsa.gov,
	sparclinux@vger.kernel.org, x86@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <linux-ia64-owner@vger.kernel.org>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After doing some things on a small issue,
I noticed through web surfing, that there were patches
submitted pertaining that __initcall is deprecated,
and device_initcall should be used.

So as a change of subject(since what I was looking at
was frustrating me),I decided to grep the whole tree
and make the change(partially).

Currently I'm running this patch on my system, kernel compiles
without any errors or warnings.(thought there would be a speed increase
but didn't see much(if any)).
Biggest problem I have though is testing this on other hardware types
(I only have a macbook,and an iMac).
So please if you have the access to other arch/hardware types please
test.

Now what I mean by partially is the __initcall function is still
there, so(if any) userspace apps/libs depend on this it's there
so they dont break and/or any other subsystem, that needs time
to make the changes.

Note:
the remaining files that still have __initcall in them are:
(according to grep)

arch/um/include/shared/init.h
include/linux/init.h
scripts/checkpatch.pl

either I or somebody else, can change this(although a bit
concerned about breaking things).

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
---
 Documentation/DocBook/kernel-hacking.tmpl    |    4 ++--
 Documentation/cpu-freq/cpu-drivers.txt       |    2 +-
 Documentation/kbuild/makefiles.txt           |    2 +-
 arch/arm/mach-at91/leds.c                    |    2 +-
 arch/arm/mach-clps711x/p720t.c               |    2 +-
 arch/arm/mach-ebsa110/leds.c                 |    2 +-
 arch/arm/mach-footbridge/cats-hw.c           |    2 +-
 arch/arm/mach-footbridge/ebsa285-leds.c      |    2 +-
 arch/arm/mach-footbridge/netwinder-hw.c      |    2 +-
 arch/arm/mach-footbridge/netwinder-leds.c    |    2 +-
 arch/arm/mach-ks8695/leds.c                  |    2 +-
 arch/arm/mach-omap1/leds.c                   |    2 +-
 arch/arm/mach-omap1/pm.c                     |    2 +-
 arch/arm/mach-orion5x/db88f5281-setup.c      |    2 +-
 arch/arm/mach-orion5x/rd88f5182-setup.c      |    2 +-
 arch/arm/mach-pxa/generic.c                  |    2 +-
 arch/arm/mach-pxa/pxa25x.c                   |    2 +-
 arch/arm/mach-shark/leds.c                   |    2 +-
 arch/blackfin/kernel/bfin_gpio.c             |    2 +-
 arch/blackfin/mach-common/pm.c               |    2 +-
 arch/cris/arch-v10/kernel/debugport.c        |    2 +-
 arch/cris/arch-v10/kernel/fasttimer.c        |    2 +-
 arch/cris/arch-v10/mm/init.c                 |    2 +-
 arch/cris/arch-v32/kernel/fasttimer.c        |    2 +-
 arch/cris/arch-v32/kernel/pinmux.c           |    2 +-
 arch/cris/arch-v32/kernel/signal.c           |    2 +-
 arch/cris/arch-v32/mach-a3/io.c              |    2 +-
 arch/cris/arch-v32/mach-a3/pinmux.c          |    2 +-
 arch/cris/arch-v32/mach-fs/io.c              |    2 +-
 arch/cris/arch-v32/mach-fs/pinmux.c          |    2 +-
 arch/cris/kernel/profile.c                   |    2 +-
 arch/cris/kernel/time.c                      |    2 +-
 arch/cris/kernel/traps.c                     |    2 +-
 arch/frv/kernel/gdb-stub.c                   |    2 +-
 arch/frv/kernel/pm-mb93093.c                 |    2 +-
 arch/frv/kernel/pm.c                         |    2 +-
 arch/frv/kernel/sysctl.c                     |    2 +-
 arch/h8300/kernel/gpio.c                     |    2 +-
 arch/ia64/hp/sim/simeth.c                    |    2 +-
 arch/ia64/hp/sim/simserial.c                 |    2 +-
 arch/ia64/kernel/audit.c                     |    2 +-
 arch/ia64/kernel/crash.c                     |    2 +-
 arch/ia64/kernel/cyclone.c                   |    2 +-
 arch/ia64/kernel/perfmon.c                   |    2 +-
 arch/ia64/kernel/setup.c                     |    2 +-
 arch/ia64/kernel/uncached.c                  |    2 +-
 arch/ia64/kernel/unwind.c                    |    2 +-
 arch/ia64/mm/init.c                          |    2 +-
 arch/mips/Makefile                           |    2 +-
 arch/mips/kernel/unaligned.c                 |    2 +-
 arch/mips/lasat/sysctl.c                     |    2 +-
 arch/mips/math-emu/cp1emu.c                  |    2 +-
 arch/mips/nxp/pnx8550/common/proc.c          |    2 +-
 arch/mips/sibyte/sb1250/bus_watcher.c        |    2 +-
 arch/mn10300/kernel/gdb-stub.c               |    2 +-
 arch/mn10300/kernel/mn10300-serial.c         |    2 +-
 arch/mn10300/kernel/profile.c                |    2 +-
 arch/parisc/kernel/pci-dma.c                 |    2 +-
 arch/parisc/kernel/pdc_chassis.c             |    2 +-
 arch/powerpc/kernel/audit.c                  |    2 +-
 arch/powerpc/kernel/idle.c                   |    2 +-
 arch/powerpc/kernel/irq.c                    |    2 +-
 arch/powerpc/kernel/proc_powerpc.c           |    2 +-
 arch/powerpc/kernel/prom.c                   |    4 ++--
 arch/powerpc/kernel/rtas-proc.c              |    2 +-
 arch/powerpc/kernel/rtasd.c                  |    2 +-
 arch/powerpc/kernel/sysfs.c                  |    2 +-
 arch/powerpc/kernel/tau_6xx.c                |    2 +-
 arch/powerpc/kernel/vio.c                    |    2 +-
 arch/powerpc/platforms/iseries/lpevents.c    |    2 +-
 arch/powerpc/platforms/iseries/mf.c          |    2 +-
 arch/powerpc/platforms/iseries/proc.c        |    2 +-
 arch/powerpc/platforms/iseries/viopath.c     |    2 +-
 arch/powerpc/platforms/pseries/eeh.c         |    2 +-
 arch/powerpc/platforms/pseries/hvCall_inst.c |    2 +-
 arch/powerpc/platforms/pseries/power.c       |    2 +-
 arch/powerpc/platforms/pseries/ras.c         |    2 +-
 arch/powerpc/platforms/pseries/reconfig.c    |    2 +-
 arch/powerpc/xmon/xmon.c                     |    2 +-
 arch/s390/appldata/appldata_base.c           |    2 +-
 arch/s390/kernel/audit.c                     |    2 +-
 arch/s390/kernel/compat_exec_domain.c        |    2 +-
 arch/s390/kernel/ipl.c                       |    2 +-
 arch/s390/kernel/topology.c                  |    2 +-
 arch/sh/boards/board-edosk7760.c             |    2 +-
 arch/sh/boards/board-sh7785lcr.c             |    2 +-
 arch/sh/boards/mach-cayman/setup.c           |    2 +-
 arch/sh/boards/mach-landisk/setup.c          |    2 +-
 arch/sh/boards/mach-r2d/setup.c              |    2 +-
 arch/sh/boards/mach-sdk7786/setup.c          |    2 +-
 arch/sh/boards/mach-se/7206/setup.c          |    2 +-
 arch/sh/boards/mach-se/7751/setup.c          |    2 +-
 arch/sh/boards/mach-sh03/setup.c             |    2 +-
 arch/sh/kernel/traps_64.c                    |    2 +-
 arch/sparc/kernel/apc.c                      |    2 +-
 arch/sparc/kernel/audit.c                    |    2 +-
 arch/sparc/kernel/mdesc.c                    |    2 +-
 arch/sparc/kernel/pmc.c                      |    2 +-
 arch/um/drivers/mconsole_kern.c              |    8 ++++----
 arch/um/drivers/net_kern.c                   |    2 +-
 arch/um/drivers/stderr_console.c             |    2 +-
 arch/um/drivers/ubd_kern.c                   |    4 ++--
 arch/um/kernel/exitcode.c                    |    2 +-
 arch/um/kernel/physmem.c                     |    2 +-
 arch/um/os-Linux/aio.c                       |    4 ++--
 arch/um/os-Linux/skas/mem.c                  |    2 +-
 arch/um/os-Linux/skas/process.c              |    2 +-
 arch/um/os-Linux/umid.c                      |    2 +-
 arch/um/sys-i386/tls.c                       |    2 +-
 arch/x86/kernel/audit_64.c                   |    2 +-
 arch/x86/kernel/tlb_uv.c                     |    4 ++--
 arch/x86/kernel/vsyscall_64.c                |    4 ++--
 arch/x86/mm/dump_pagetables.c                |    2 +-
 arch/x86/vdso/vdso32-setup.c                 |    4 ++--
 arch/x86/vdso/vma.c                          |    2 +-
 arch/xtensa/platforms/iss/console.c          |    2 +-
 drivers/net/arm/am79c961a.c                  |    2 +-
 drivers/net/hamradio/baycom_epp.c            |    1 +
 drivers/net/hamradio/baycom_par.c            |    1 +
 drivers/net/hamradio/baycom_ser_fdx.c        |    1 +
 drivers/net/hamradio/baycom_ser_hdx.c        |    1 +
 drivers/s390/char/sclp_cmd.c                 |    2 +-
 drivers/s390/char/sclp_config.c              |    2 +-
 drivers/s390/char/sclp_cpi_sys.c             |    2 +-
 drivers/s390/char/sclp_vt220.c               |    2 +-
 drivers/s390/cio/blacklist.c                 |    2 +-
 drivers/staging/rtl8192u/ieee80211/api.c     |    2 +-
 fs/aio.c                                     |    2 +-
 fs/compat_ioctl.c                            |    2 +-
 ipc/ipc_sysctl.c                             |    2 +-
 ipc/mqueue.c                                 |    2 +-
 ipc/util.c                                   |    2 +-
 kernel/audit.c                               |    2 +-
 kernel/audit_tree.c                          |    2 +-
 kernel/dma.c                                 |    2 +-
 kernel/futex.c                               |    2 +-
 kernel/lockdep_proc.c                        |    2 +-
 kernel/pid_namespace.c                       |    2 +-
 kernel/posix-cpu-timers.c                    |    2 +-
 kernel/posix-timers.c                        |    2 +-
 kernel/resource.c                            |    2 +-
 kernel/sched_debug.c                         |    2 +-
 kernel/time/timer_list.c                     |    2 +-
 kernel/time/timer_stats.c                    |    2 +-
 kernel/tracepoint.c                          |    2 +-
 kernel/utsname_sysctl.c                      |    2 +-
 lib/audit.c                                  |    2 +-
 lib/debugobjects.c                           |    2 +-
 mm/bounce.c                                  |    2 +-
 mm/memory.c                                  |    2 +-
 mm/mm_init.c                                 |    2 +-
 mm/slab.c                                    |    2 +-
 mm/slub.c                                    |    2 +-
 mm/swapfile.c                                |    2 +-
 net/ipv4/syncookies.c                        |    2 +-
 net/ipv4/sysctl_net_ipv4.c                   |    2 +-
 security/keys/proc.c                         |    2 +-
 security/selinux/hooks.c                     |    2 +-
 security/selinux/netif.c                     |    2 +-
 security/selinux/netlink.c                   |    2 +-
 security/selinux/netnode.c                   |    2 +-
 security/selinux/netport.c                   |    2 +-
 security/selinux/selinuxfs.c                 |    2 +-
 security/selinux/ss/services.c               |    2 +-
 security/smack/smackfs.c                     |    2 +-
 sound/last.c                                 |    2 +-
 166 files changed, 176 insertions(+), 172 deletions(-)

diff --git a/Documentation/DocBook/kernel-hacking.tmpl b/Documentation/DocBook/kernel-hacking.tmpl
index 7b3f493..a682709 100644
--- a/Documentation/DocBook/kernel-hacking.tmpl
+++ b/Documentation/DocBook/kernel-hacking.tmpl
@@ -734,7 +734,7 @@ printk(KERN_INFO "my ip: %pI4\n", &amp;ipaddress);
   </sect1>
 
   <sect1 id="routines-init-again">
-   <title><function>__initcall()</function>/<function>module_init()</function>
+   <title><function>device_initcall()</function>/<function>module_init()</function>
     <filename class="headerfile">include/linux/init.h</filename></title>
    <para>
     Many parts of the kernel are well served as a module
@@ -750,7 +750,7 @@ printk(KERN_INFO "my ip: %pI4\n", &amp;ipaddress);
     function is to be called at module insertion time (if the file is
     compiled as a module), or at boot time: if the file is not
     compiled as a module the <function>module_init()</function> macro
-    becomes equivalent to <function>__initcall()</function>, which
+    becomes equivalent to <function>device_initcall()</function>, which
     through linker magic ensures that the function is called on boot.
    </para>
 
diff --git a/Documentation/cpu-freq/cpu-drivers.txt b/Documentation/cpu-freq/cpu-drivers.txt
index 6c30e93..12bb6e4 100644
--- a/Documentation/cpu-freq/cpu-drivers.txt
+++ b/Documentation/cpu-freq/cpu-drivers.txt
@@ -41,7 +41,7 @@ on what is necessary:
 1.1 Initialization
 ------------------
 
-First of all, in an __initcall level 7 (module_init()) or later
+First of all, in an device_initcall level 7 (module_init()) or later
 function check whether this kernel runs on the right CPU and the right
 chipset. If so, register a struct cpufreq_driver with the CPUfreq core
 using cpufreq_register_driver()
diff --git a/Documentation/kbuild/makefiles.txt b/Documentation/kbuild/makefiles.txt
index 71c602d..645ea71 100644
--- a/Documentation/kbuild/makefiles.txt
+++ b/Documentation/kbuild/makefiles.txt
@@ -159,7 +159,7 @@ more details, with real examples.
 	built-in.o and succeeding instances will be ignored.
 
 	Link order is significant, because certain functions
-	(module_init() / __initcall) will be called during boot in the
+	(module_init() / device_initcall) will be called during boot in the
 	order they appear. So keep in mind that changing the link
 	order may e.g. change the order in which your SCSI
 	controllers are detected, and thus your disks are renumbered.
diff --git a/arch/arm/mach-at91/leds.c b/arch/arm/mach-at91/leds.c
index 0415a83..08e342d 100644
--- a/arch/arm/mach-at91/leds.c
+++ b/arch/arm/mach-at91/leds.c
@@ -179,7 +179,7 @@ static int __init leds_init(void)
 	return 0;
 }
 
-__initcall(leds_init);
+device_initcall(leds_init);
 
 
 void __init at91_init_leds(u8 cpu_led, u8 timer_led)
diff --git a/arch/arm/mach-clps711x/p720t.c b/arch/arm/mach-clps711x/p720t.c
index 0d94a30..1047b23 100644
--- a/arch/arm/mach-clps711x/p720t.c
+++ b/arch/arm/mach-clps711x/p720t.c
@@ -121,5 +121,5 @@ static int p720t_hw_init(void)
 	return 0;
 }
 
-__initcall(p720t_hw_init);
+device_initcall(p720t_hw_init);
 
diff --git a/arch/arm/mach-ebsa110/leds.c b/arch/arm/mach-ebsa110/leds.c
index 6a6ea57..8b57907 100644
--- a/arch/arm/mach-ebsa110/leds.c
+++ b/arch/arm/mach-ebsa110/leds.c
@@ -48,4 +48,4 @@ static int __init leds_init(void)
 	return 0;
 }
 
-__initcall(leds_init);
+device_initcall(leds_init);
diff --git a/arch/arm/mach-footbridge/cats-hw.c b/arch/arm/mach-footbridge/cats-hw.c
index 1b996b2..1b616e5 100644
--- a/arch/arm/mach-footbridge/cats-hw.c
+++ b/arch/arm/mach-footbridge/cats-hw.c
@@ -69,7 +69,7 @@ static int __init cats_hw_init(void)
 	return 0;
 }
 
-__initcall(cats_hw_init);
+device_initcall(cats_hw_init);
 
 /*
  * CATS uses soft-reboot by default, since
diff --git a/arch/arm/mach-footbridge/ebsa285-leds.c b/arch/arm/mach-footbridge/ebsa285-leds.c
index 4e10090..f162fb2 100644
--- a/arch/arm/mach-footbridge/ebsa285-leds.c
+++ b/arch/arm/mach-footbridge/ebsa285-leds.c
@@ -136,4 +136,4 @@ static int __init leds_init(void)
 	return 0;
 }
 
-__initcall(leds_init);
+device_initcall(leds_init);
diff --git a/arch/arm/mach-footbridge/netwinder-hw.c b/arch/arm/mach-footbridge/netwinder-hw.c
index ac7ffa6..090b4cf 100644
--- a/arch/arm/mach-footbridge/netwinder-hw.c
+++ b/arch/arm/mach-footbridge/netwinder-hw.c
@@ -623,7 +623,7 @@ static int __init nw_hw_init(void)
 	return 0;
 }
 
-__initcall(nw_hw_init);
+device_initcall(nw_hw_init);
 
 /*
  * Older NeTTroms either do not provide a parameters
diff --git a/arch/arm/mach-footbridge/netwinder-leds.c b/arch/arm/mach-footbridge/netwinder-leds.c
index 00269fe..f504682 100644
--- a/arch/arm/mach-footbridge/netwinder-leds.c
+++ b/arch/arm/mach-footbridge/netwinder-leds.c
@@ -136,4 +136,4 @@ static int __init leds_init(void)
 	return 0;
 }
 
-__initcall(leds_init);
+device_initcall(leds_init);
diff --git a/arch/arm/mach-ks8695/leds.c b/arch/arm/mach-ks8695/leds.c
index 184ef74..97c3828 100644
--- a/arch/arm/mach-ks8695/leds.c
+++ b/arch/arm/mach-ks8695/leds.c
@@ -90,4 +90,4 @@ static int __init leds_init(void)
 	return 0;
 }
 
-__initcall(leds_init);
+device_initcall(leds_init);
diff --git a/arch/arm/mach-omap1/leds.c b/arch/arm/mach-omap1/leds.c
index 277f356..bd447fa 100644
--- a/arch/arm/mach-omap1/leds.c
+++ b/arch/arm/mach-omap1/leds.c
@@ -63,4 +63,4 @@ omap_leds_init(void)
 	return 0;
 }
 
-__initcall(omap_leds_init);
+device_initcall(omap_leds_init);
diff --git a/arch/arm/mach-omap1/pm.c b/arch/arm/mach-omap1/pm.c
index b1d3f9f..fda5f60 100644
--- a/arch/arm/mach-omap1/pm.c
+++ b/arch/arm/mach-omap1/pm.c
@@ -724,4 +724,4 @@ static int __init omap_pm_init(void)
 
 	return 0;
 }
-__initcall(omap_pm_init);
+device_initcall(omap_pm_init);
diff --git a/arch/arm/mach-orion5x/db88f5281-setup.c b/arch/arm/mach-orion5x/db88f5281-setup.c
index d318bea..0c76893 100644
--- a/arch/arm/mach-orion5x/db88f5281-setup.c
+++ b/arch/arm/mach-orion5x/db88f5281-setup.c
@@ -197,7 +197,7 @@ static int __init db88f5281_7seg_init(void)
 	return 0;
 }
 
-__initcall(db88f5281_7seg_init);
+device_initcall(db88f5281_7seg_init);
 
 /*****************************************************************************
  * PCI
diff --git a/arch/arm/mach-orion5x/rd88f5182-setup.c b/arch/arm/mach-orion5x/rd88f5182-setup.c
index a04f9e4..43e9a49 100644
--- a/arch/arm/mach-orion5x/rd88f5182-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5182-setup.c
@@ -130,7 +130,7 @@ static int __init rd88f5182_dbgled_init(void)
 	return 0;
 }
 
-__initcall(rd88f5182_dbgled_init);
+device_initcall(rd88f5182_dbgled_init);
 
 #endif
 
diff --git a/arch/arm/mach-pxa/generic.c b/arch/arm/mach-pxa/generic.c
index 3126a35..1d44a9a 100644
--- a/arch/arm/mach-pxa/generic.c
+++ b/arch/arm/mach-pxa/generic.c
@@ -12,7 +12,7 @@
  * published by the Free Software Foundation.
  *
  * Since this file should be linked before any other machine specific file,
- * the __initcall() here will be executed first.  This serves as default
+ * the device_initcall() here will be executed first.  This serves as default
  * initialization stuff for PXA machines which can be overridden later if
  * need be.
  */
diff --git a/arch/arm/mach-pxa/pxa25x.c b/arch/arm/mach-pxa/pxa25x.c
index 0b9ad30..b0df545 100644
--- a/arch/arm/mach-pxa/pxa25x.c
+++ b/arch/arm/mach-pxa/pxa25x.c
@@ -12,7 +12,7 @@
  * published by the Free Software Foundation.
  *
  * Since this file should be linked before any other machine specific file,
- * the __initcall() here will be executed first.  This serves as default
+ * the device_initcall() here will be executed first.  This serves as default
  * initialization stuff for PXA machines which can be overridden later if
  * need be.
  */
diff --git a/arch/arm/mach-shark/leds.c b/arch/arm/mach-shark/leds.c
index c9e32de..511693a 100644
--- a/arch/arm/mach-shark/leds.c
+++ b/arch/arm/mach-shark/leds.c
@@ -163,4 +163,4 @@ static int __init leds_init(void)
 	return 0;
 }
 
-__initcall(leds_init);
+device_initcall(leds_init);
diff --git a/arch/blackfin/kernel/bfin_gpio.c b/arch/blackfin/kernel/bfin_gpio.c
index a174596..bc5ba54 100644
--- a/arch/blackfin/kernel/bfin_gpio.c
+++ b/arch/blackfin/kernel/bfin_gpio.c
@@ -1285,7 +1285,7 @@ static __init int gpio_register_proc(void)
 		proc_gpio->read_proc = gpio_proc_read;
 	return proc_gpio != NULL;
 }
-__initcall(gpio_register_proc);
+device_initcall(gpio_register_proc);
 #endif
 
 #ifdef CONFIG_GPIOLIB
diff --git a/arch/blackfin/mach-common/pm.c b/arch/blackfin/mach-common/pm.c
index 8837be4..dc36d3a 100644
--- a/arch/blackfin/mach-common/pm.c
+++ b/arch/blackfin/mach-common/pm.c
@@ -266,4 +266,4 @@ static int __init bfin_pm_init(void)
 	return 0;
 }
 
-__initcall(bfin_pm_init);
+device_initcall(bfin_pm_init);
diff --git a/arch/cris/arch-v10/kernel/debugport.c b/arch/cris/arch-v10/kernel/debugport.c
index 99851ba..0348977 100644
--- a/arch/cris/arch-v10/kernel/debugport.c
+++ b/arch/cris/arch-v10/kernel/debugport.c
@@ -564,4 +564,4 @@ init_etrax_debug(void)
 #endif
 	return 0;
 }
-__initcall(init_etrax_debug);
+device_initcall(init_etrax_debug);
diff --git a/arch/cris/arch-v10/kernel/fasttimer.c b/arch/cris/arch-v10/kernel/fasttimer.c
index 5ff08a8..b991462 100644
--- a/arch/cris/arch-v10/kernel/fasttimer.c
+++ b/arch/cris/arch-v10/kernel/fasttimer.c
@@ -879,4 +879,4 @@ int fast_timer_init(void)
   }
 	return 0;
 }
-__initcall(fast_timer_init);
+device_initcall(fast_timer_init);
diff --git a/arch/cris/arch-v10/mm/init.c b/arch/cris/arch-v10/mm/init.c
index baa746c..908d829 100644
--- a/arch/cris/arch-v10/mm/init.c
+++ b/arch/cris/arch-v10/mm/init.c
@@ -217,7 +217,7 @@ __init init_ioremap(void)
 	return 0;
 }
 
-__initcall(init_ioremap);
+device_initcall(init_ioremap);
 
 /* Helper function for the two below */
 
diff --git a/arch/cris/arch-v32/kernel/fasttimer.c b/arch/cris/arch-v32/kernel/fasttimer.c
index 111caa1..221bcea 100644
--- a/arch/cris/arch-v32/kernel/fasttimer.c
+++ b/arch/cris/arch-v32/kernel/fasttimer.c
@@ -833,4 +833,4 @@ int fast_timer_init(void)
   }
 	return 0;
 }
-__initcall(fast_timer_init);
+device_initcall(fast_timer_init);
diff --git a/arch/cris/arch-v32/kernel/pinmux.c b/arch/cris/arch-v32/kernel/pinmux.c
index f6f3637..c2dfcd3 100644
--- a/arch/cris/arch-v32/kernel/pinmux.c
+++ b/arch/cris/arch-v32/kernel/pinmux.c
@@ -226,4 +226,4 @@ crisv32_pinmux_dump(void)
 	}
 }
 
-__initcall(crisv32_pinmux_init);
+device_initcall(crisv32_pinmux_init);
diff --git a/arch/cris/arch-v32/kernel/signal.c b/arch/cris/arch-v32/kernel/signal.c
index 372d0ca..d1e1b4e 100644
--- a/arch/cris/arch-v32/kernel/signal.c
+++ b/arch/cris/arch-v32/kernel/signal.c
@@ -672,4 +672,4 @@ cris_init_signal(void)
 	return 0;
 }
 
-__initcall(cris_init_signal);
+device_initcall(cris_init_signal);
diff --git a/arch/cris/arch-v32/mach-a3/io.c b/arch/cris/arch-v32/mach-a3/io.c
index 090ceb9..ea40a9b 100644
--- a/arch/cris/arch-v32/mach-a3/io.c
+++ b/arch/cris/arch-v32/mach-a3/io.c
@@ -95,7 +95,7 @@ static int __init crisv32_io_init(void)
 	return ret;
 }
 
-__initcall(crisv32_io_init);
+device_initcall(crisv32_io_init);
 
 int crisv32_io_get(struct crisv32_iopin *iopin,
 	unsigned int port, unsigned int pin)
diff --git a/arch/cris/arch-v32/mach-a3/pinmux.c b/arch/cris/arch-v32/mach-a3/pinmux.c
index 18648ef..14bbc78 100644
--- a/arch/cris/arch-v32/mach-a3/pinmux.c
+++ b/arch/cris/arch-v32/mach-a3/pinmux.c
@@ -383,4 +383,4 @@ crisv32_pinmux_dump(void)
 	}
 }
 
-__initcall(crisv32_pinmux_init);
+device_initcall(crisv32_pinmux_init);
diff --git a/arch/cris/arch-v32/mach-fs/io.c b/arch/cris/arch-v32/mach-fs/io.c
index a695866..fce8438 100644
--- a/arch/cris/arch-v32/mach-fs/io.c
+++ b/arch/cris/arch-v32/mach-fs/io.c
@@ -128,7 +128,7 @@ static int __init crisv32_io_init(void)
 	return ret;
 }
 
-__initcall(crisv32_io_init);
+device_initcall(crisv32_io_init);
 
 int crisv32_io_get(struct crisv32_iopin *iopin,
 		   unsigned int port, unsigned int pin)
diff --git a/arch/cris/arch-v32/mach-fs/pinmux.c b/arch/cris/arch-v32/mach-fs/pinmux.c
index 38f29ee..751f991 100644
--- a/arch/cris/arch-v32/mach-fs/pinmux.c
+++ b/arch/cris/arch-v32/mach-fs/pinmux.c
@@ -306,4 +306,4 @@ void crisv32_pinmux_dump(void)
 	}
 }
 
-__initcall(crisv32_pinmux_init);
+device_initcall(crisv32_pinmux_init);
diff --git a/arch/cris/kernel/profile.c b/arch/cris/kernel/profile.c
index 9aa5711..2472f3f 100644
--- a/arch/cris/kernel/profile.c
+++ b/arch/cris/kernel/profile.c
@@ -82,4 +82,4 @@ __init init_cris_profile(void)
 	return 0;
 }
 
-__initcall(init_cris_profile);
+device_initcall(init_cris_profile);
diff --git a/arch/cris/kernel/time.c b/arch/cris/kernel/time.c
index a05dd31..7554e96 100644
--- a/arch/cris/kernel/time.c
+++ b/arch/cris/kernel/time.c
@@ -160,4 +160,4 @@ __init init_udelay(void)
 	return 0;
 }
 
-__initcall(init_udelay);
+device_initcall(init_udelay);
diff --git a/arch/cris/kernel/traps.c b/arch/cris/kernel/traps.c
index 541efbf..8f77b68 100644
--- a/arch/cris/kernel/traps.c
+++ b/arch/cris/kernel/traps.c
@@ -177,7 +177,7 @@ oops_nmi_register(void)
 	return 0;
 }
 
-__initcall(oops_nmi_register);
+device_initcall(oops_nmi_register);
 
 #endif
 
diff --git a/arch/frv/kernel/gdb-stub.c b/arch/frv/kernel/gdb-stub.c
index 7ca8a6b..71d564c 100644
--- a/arch/frv/kernel/gdb-stub.c
+++ b/arch/frv/kernel/gdb-stub.c
@@ -2017,7 +2017,7 @@ static int __init gdbstub_postinit(void)
 	return 0;
 } /* end gdbstub_postinit() */
 
-__initcall(gdbstub_postinit);
+device_initcall(gdbstub_postinit);
 #endif
 
 /*****************************************************************************/
diff --git a/arch/frv/kernel/pm-mb93093.c b/arch/frv/kernel/pm-mb93093.c
index eaa7b58..3caa348 100644
--- a/arch/frv/kernel/pm-mb93093.c
+++ b/arch/frv/kernel/pm-mb93093.c
@@ -61,5 +61,5 @@ static int __init mb93093_pm_init(void)
 	return 0;
 }
 
-__initcall(mb93093_pm_init);
+device_initcall(mb93093_pm_init);
 
diff --git a/arch/frv/kernel/pm.c b/arch/frv/kernel/pm.c
index 5fa3889..b1aad48 100644
--- a/arch/frv/kernel/pm.c
+++ b/arch/frv/kernel/pm.c
@@ -348,6 +348,6 @@ static int __init pm_init(void)
 	return 0;
 }
 
-__initcall(pm_init);
+device_initcall(pm_init);
 
 #endif
diff --git a/arch/frv/kernel/sysctl.c b/arch/frv/kernel/sysctl.c
index 035516c..3280f8b 100644
--- a/arch/frv/kernel/sysctl.c
+++ b/arch/frv/kernel/sysctl.c
@@ -217,4 +217,4 @@ static int __init frv_sysctl_init(void)
 	return 0;
 }
 
-__initcall(frv_sysctl_init);
+device_initcall(frv_sysctl_init);
diff --git a/arch/h8300/kernel/gpio.c b/arch/h8300/kernel/gpio.c
index 6a25dd5..6ea7dd9 100644
--- a/arch/h8300/kernel/gpio.c
+++ b/arch/h8300/kernel/gpio.c
@@ -164,7 +164,7 @@ static __init int register_proc(void)
 	return proc_gpio != NULL;
 }
 
-__initcall(register_proc);
+device_initcall(register_proc);
 #endif
 
 void __init h8300_gpio_init(void)
diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index 7e81966..e669908 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -524,4 +524,4 @@ set_multicast_list(struct net_device *dev)
 	printk(KERN_WARNING "%s: set_multicast_list called\n", dev->name);
 }
 
-__initcall(simeth_probe);
+device_initcall(simeth_probe);
diff --git a/arch/ia64/hp/sim/simserial.c b/arch/ia64/hp/sim/simserial.c
index 2bef526..470c0a1 100644
--- a/arch/ia64/hp/sim/simserial.c
+++ b/arch/ia64/hp/sim/simserial.c
@@ -980,5 +980,5 @@ simrs_init (void)
 }
 
 #ifndef MODULE
-__initcall(simrs_init);
+device_initcall(simrs_init);
 #endif
diff --git a/arch/ia64/kernel/audit.c b/arch/ia64/kernel/audit.c
index 96a9d18..c7d79ba 100644
--- a/arch/ia64/kernel/audit.c
+++ b/arch/ia64/kernel/audit.c
@@ -57,4 +57,4 @@ static int __init audit_classes_init(void)
 	return 0;
 }
 
-__initcall(audit_classes_init);
+device_initcall(audit_classes_init);
diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index b942f40..07218af 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -282,5 +282,5 @@ machine_crash_setup(void)
 	return 0;
 }
 
-__initcall(machine_crash_setup);
+device_initcall(machine_crash_setup);
 
diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
index 71e3586..66fb97e 100644
--- a/arch/ia64/kernel/cyclone.c
+++ b/arch/ia64/kernel/cyclone.c
@@ -125,4 +125,4 @@ int __init init_cyclone_clock(void)
 	return 0;
 }
 
-__initcall(init_cyclone_clock);
+device_initcall(init_cyclone_clock);
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 703062c..cb7199a 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -6700,7 +6700,7 @@ pfm_init(void)
 	return 0;
 }
 
-__initcall(pfm_init);
+device_initcall(pfm_init);
 
 /*
  * this function is called before pfm_init()
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 41ae6a5..8322a01 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -243,7 +243,7 @@ static int __init register_memory(void)
 	return 0;
 }
 
-__initcall(register_memory);
+device_initcall(register_memory);
 
 
 #ifdef CONFIG_KEXEC
diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index a595823..4a9812f 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -279,4 +279,4 @@ static int __init uncached_init(void)
 	return 0;
 }
 
-__initcall(uncached_init);
+device_initcall(uncached_init);
diff --git a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
index b6c0e63..62de896 100644
--- a/arch/ia64/kernel/unwind.c
+++ b/arch/ia64/kernel/unwind.c
@@ -2223,7 +2223,7 @@ create_gate_table (void)
 	return 0;
 }
 
-__initcall(create_gate_table);
+device_initcall(create_gate_table);
 
 void __init
 unw_init (void)
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index ed41759..da31b31 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -716,4 +716,4 @@ per_linux32_init(void)
 	return 0;
 }
 
-__initcall(per_linux32_init);
+device_initcall(per_linux32_init);
diff --git a/arch/mips/Makefile b/arch/mips/Makefile
index 2f2eac2..0341a9e 100644
--- a/arch/mips/Makefile
+++ b/arch/mips/Makefile
@@ -534,7 +534,7 @@ load-$(CONFIG_SGI_IP32)		+= 0xffffffff80004000
 #
 # This is a LIB so that it links at the end, and initcalls are later
 # the sequence; but it is built as an object so that modules don't get
-# removed (as happens, even if they have __initcall/module_init)
+# removed (as happens, even if they have device_initcall/module_init)
 #
 core-$(CONFIG_SIBYTE_BCM112X)	+= arch/mips/sibyte/sb1250/
 core-$(CONFIG_SIBYTE_BCM112X)	+= arch/mips/sibyte/common/
diff --git a/arch/mips/kernel/unaligned.c b/arch/mips/kernel/unaligned.c
index 69b039c..7233ac8 100644
--- a/arch/mips/kernel/unaligned.c
+++ b/arch/mips/kernel/unaligned.c
@@ -567,5 +567,5 @@ static int __init debugfs_unaligned(void)
 		return -ENOMEM;
 	return 0;
 }
-__initcall(debugfs_unaligned);
+device_initcall(debugfs_unaligned);
 #endif
diff --git a/arch/mips/lasat/sysctl.c b/arch/mips/lasat/sysctl.c
index d87ffd0..6cc8d2f 100644
--- a/arch/mips/lasat/sysctl.c
+++ b/arch/mips/lasat/sysctl.c
@@ -285,4 +285,4 @@ static int __init lasat_register_sysctl(void)
 	return 0;
 }
 
-__initcall(lasat_register_sysctl);
+device_initcall(lasat_register_sysctl);
diff --git a/arch/mips/math-emu/cp1emu.c b/arch/mips/math-emu/cp1emu.c
index 8f2f8e9..3936be4 100644
--- a/arch/mips/math-emu/cp1emu.c
+++ b/arch/mips/math-emu/cp1emu.c
@@ -1325,5 +1325,5 @@ static int __init debugfs_fpuemu(void)
 
 	return 0;
 }
-__initcall(debugfs_fpuemu);
+device_initcall(debugfs_fpuemu);
 #endif
diff --git a/arch/mips/nxp/pnx8550/common/proc.c b/arch/mips/nxp/pnx8550/common/proc.c
index af094cd..9a10d8c 100644
--- a/arch/mips/nxp/pnx8550/common/proc.c
+++ b/arch/mips/nxp/pnx8550/common/proc.c
@@ -108,4 +108,4 @@ static int pnx8550_proc_init( void )
 	return 0;
 }
 
-__initcall(pnx8550_proc_init);
+device_initcall(pnx8550_proc_init);
diff --git a/arch/mips/sibyte/sb1250/bus_watcher.c b/arch/mips/sibyte/sb1250/bus_watcher.c
index 45274bd..e8e7f23 100644
--- a/arch/mips/sibyte/sb1250/bus_watcher.c
+++ b/arch/mips/sibyte/sb1250/bus_watcher.c
@@ -255,4 +255,4 @@ int __init sibyte_bus_watcher(void)
 	return 0;
 }
 
-__initcall(sibyte_bus_watcher);
+device_initcall(sibyte_bus_watcher);
diff --git a/arch/mn10300/kernel/gdb-stub.c b/arch/mn10300/kernel/gdb-stub.c
index 41b1170..22e0613 100644
--- a/arch/mn10300/kernel/gdb-stub.c
+++ b/arch/mn10300/kernel/gdb-stub.c
@@ -1884,7 +1884,7 @@ static int __init gdbstub_postinit(void)
 	return 0;
 }
 
-__initcall(gdbstub_postinit);
+device_initcall(gdbstub_postinit);
 #endif
 
 /*
diff --git a/arch/mn10300/kernel/mn10300-serial.c b/arch/mn10300/kernel/mn10300-serial.c
index ef34d5a..9cada2f 100644
--- a/arch/mn10300/kernel/mn10300-serial.c
+++ b/arch/mn10300/kernel/mn10300-serial.c
@@ -1350,7 +1350,7 @@ static int __init mn10300_serial_init(void)
 	return ret;
 }
 
-__initcall(mn10300_serial_init);
+device_initcall(mn10300_serial_init);
 
 
 #ifdef CONFIG_MN10300_TTYSM_CONSOLE
diff --git a/arch/mn10300/kernel/profile.c b/arch/mn10300/kernel/profile.c
index 20d7d03..e799032 100644
--- a/arch/mn10300/kernel/profile.c
+++ b/arch/mn10300/kernel/profile.c
@@ -48,4 +48,4 @@ static __init int profile_init(void)
 	return 0;
 }
 
-__initcall(profile_init);
+device_initcall(profile_init);
diff --git a/arch/parisc/kernel/pci-dma.c b/arch/parisc/kernel/pci-dma.c
index c07f618..e7c12c0 100644
--- a/arch/parisc/kernel/pci-dma.c
+++ b/arch/parisc/kernel/pci-dma.c
@@ -410,7 +410,7 @@ pcxl_dma_init(void)
 	return 0;
 }
 
-__initcall(pcxl_dma_init);
+device_initcall(pcxl_dma_init);
 
 static void * pa11_dma_alloc_consistent (struct device *dev, size_t size, dma_addr_t *dma_handle, gfp_t flag)
 {
diff --git a/arch/parisc/kernel/pdc_chassis.c b/arch/parisc/kernel/pdc_chassis.c
index d47ba1a..35ad4cb 100644
--- a/arch/parisc/kernel/pdc_chassis.c
+++ b/arch/parisc/kernel/pdc_chassis.c
@@ -295,7 +295,7 @@ static int __init pdc_chassis_create_procfs(void)
 	return 0;
 }
 
-__initcall(pdc_chassis_create_procfs);
+device_initcall(pdc_chassis_create_procfs);
 
 #endif /* CONFIG_PROC_FS */
 #endif /* CONFIG_PDC_CHASSIS_WARN */
diff --git a/arch/powerpc/kernel/audit.c b/arch/powerpc/kernel/audit.c
index a4dab7c..e721e2e 100644
--- a/arch/powerpc/kernel/audit.c
+++ b/arch/powerpc/kernel/audit.c
@@ -80,4 +80,4 @@ static int __init audit_classes_init(void)
 	return 0;
 }
 
-__initcall(audit_classes_init);
+device_initcall(audit_classes_init);
diff --git a/arch/powerpc/kernel/idle.c b/arch/powerpc/kernel/idle.c
index 049dda6..694861f 100644
--- a/arch/powerpc/kernel/idle.c
+++ b/arch/powerpc/kernel/idle.c
@@ -134,5 +134,5 @@ register_powersave_nap_sysctl(void)
 
 	return 0;
 }
-__initcall(register_powersave_nap_sysctl);
+device_initcall(register_powersave_nap_sysctl);
 #endif
diff --git a/arch/powerpc/kernel/irq.c b/arch/powerpc/kernel/irq.c
index 64f6f20..2e97ae9 100644
--- a/arch/powerpc/kernel/irq.c
+++ b/arch/powerpc/kernel/irq.c
@@ -1203,7 +1203,7 @@ static int __init irq_debugfs_init(void)
 
 	return 0;
 }
-__initcall(irq_debugfs_init);
+device_initcall(irq_debugfs_init);
 #endif /* CONFIG_VIRQ_DEBUG */
 
 #ifdef CONFIG_PPC64
diff --git a/arch/powerpc/kernel/proc_powerpc.c b/arch/powerpc/kernel/proc_powerpc.c
index 1ed3b8d..f53bdca 100644
--- a/arch/powerpc/kernel/proc_powerpc.c
+++ b/arch/powerpc/kernel/proc_powerpc.c
@@ -91,7 +91,7 @@ static int __init proc_ppc64_init(void)
 
 	return 0;
 }
-__initcall(proc_ppc64_init);
+device_initcall(proc_ppc64_init);
 
 #endif /* CONFIG_PPC64 */
 
diff --git a/arch/powerpc/kernel/prom.c b/arch/powerpc/kernel/prom.c
index 05131d6..628d6df 100644
--- a/arch/powerpc/kernel/prom.c
+++ b/arch/powerpc/kernel/prom.c
@@ -845,7 +845,7 @@ static int __init prom_reconfig_setup(void)
 {
 	return pSeries_reconfig_notifier_register(&prom_reconfig_nb);
 }
-__initcall(prom_reconfig_setup);
+device_initcall(prom_reconfig_setup);
 #endif
 
 /* Find the device node for a given logical cpu number, also returns the cpu
@@ -909,5 +909,5 @@ static int __init export_flat_device_tree(void)
 
 	return 0;
 }
-__initcall(export_flat_device_tree);
+device_initcall(export_flat_device_tree);
 #endif
diff --git a/arch/powerpc/kernel/rtas-proc.c b/arch/powerpc/kernel/rtas-proc.c
index 8777fb0..7578df5 100644
--- a/arch/powerpc/kernel/rtas-proc.c
+++ b/arch/powerpc/kernel/rtas-proc.c
@@ -279,7 +279,7 @@ static int __init proc_rtas_init(void)
 	return 0;
 }
 
-__initcall(proc_rtas_init);
+device_initcall(proc_rtas_init);
 
 static int parse_number(const char __user *p, size_t count, unsigned long *val)
 {
diff --git a/arch/powerpc/kernel/rtasd.c b/arch/powerpc/kernel/rtasd.c
index 2e4832a..1bfd919 100644
--- a/arch/powerpc/kernel/rtasd.c
+++ b/arch/powerpc/kernel/rtasd.c
@@ -508,7 +508,7 @@ static int __init rtas_init(void)
 
 	return 0;
 }
-__initcall(rtas_init);
+device_initcall(rtas_init);
 
 static int __init surveillance_setup(char *str)
 {
diff --git a/arch/powerpc/kernel/sysfs.c b/arch/powerpc/kernel/sysfs.c
index e235e52..6ddb889 100644
--- a/arch/powerpc/kernel/sysfs.c
+++ b/arch/powerpc/kernel/sysfs.c
@@ -92,7 +92,7 @@ static int __init smt_setup(void)
 	of_node_put(options);
 	return 0;
 }
-__initcall(smt_setup);
+device_initcall(smt_setup);
 
 static int __init setup_smt_snooze_delay(char *str)
 {
diff --git a/arch/powerpc/kernel/tau_6xx.c b/arch/powerpc/kernel/tau_6xx.c
index a753b72..a38d207 100644
--- a/arch/powerpc/kernel/tau_6xx.c
+++ b/arch/powerpc/kernel/tau_6xx.c
@@ -248,7 +248,7 @@ int __init TAU_init(void)
 	return 0;
 }
 
-__initcall(TAU_init);
+device_initcall(TAU_init);
 
 /*
  * return current temp
diff --git a/arch/powerpc/kernel/vio.c b/arch/powerpc/kernel/vio.c
index 77f6421..c74aae9 100644
--- a/arch/powerpc/kernel/vio.c
+++ b/arch/powerpc/kernel/vio.c
@@ -1303,7 +1303,7 @@ static int __init vio_bus_init(void)
 
 	return 0;
 }
-__initcall(vio_bus_init);
+device_initcall(vio_bus_init);
 
 static ssize_t name_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
diff --git a/arch/powerpc/platforms/iseries/lpevents.c b/arch/powerpc/platforms/iseries/lpevents.c
index b0f8a85..66bc6ff 100644
--- a/arch/powerpc/platforms/iseries/lpevents.c
+++ b/arch/powerpc/platforms/iseries/lpevents.c
@@ -337,5 +337,5 @@ static int __init proc_lpevents_init(void)
 		    &proc_lpevents_operations);
 	return 0;
 }
-__initcall(proc_lpevents_init);
+device_initcall(proc_lpevents_init);
 
diff --git a/arch/powerpc/platforms/iseries/mf.c b/arch/powerpc/platforms/iseries/mf.c
index 6617915..d140c09 100644
--- a/arch/powerpc/platforms/iseries/mf.c
+++ b/arch/powerpc/platforms/iseries/mf.c
@@ -1299,7 +1299,7 @@ static int __init mf_proc_init(void)
 	return 0;
 }
 
-__initcall(mf_proc_init);
+device_initcall(mf_proc_init);
 
 #endif /* CONFIG_PROC_FS */
 
diff --git a/arch/powerpc/platforms/iseries/proc.c b/arch/powerpc/platforms/iseries/proc.c
index 0676368..1e9ac90 100644
--- a/arch/powerpc/platforms/iseries/proc.c
+++ b/arch/powerpc/platforms/iseries/proc.c
@@ -117,4 +117,4 @@ static int __init iseries_proc_init(void)
 		    &proc_titantod_operations);
 	return 0;
 }
-__initcall(iseries_proc_init);
+device_initcall(iseries_proc_init);
diff --git a/arch/powerpc/platforms/iseries/viopath.c b/arch/powerpc/platforms/iseries/viopath.c
index 5aea94f..daac760 100644
--- a/arch/powerpc/platforms/iseries/viopath.c
+++ b/arch/powerpc/platforms/iseries/viopath.c
@@ -186,7 +186,7 @@ static int __init vio_proc_init(void)
 	proc_create("iSeries/config", 0, NULL, &proc_viopath_operations);
         return 0;
 }
-__initcall(vio_proc_init);
+device_initcall(vio_proc_init);
 
 /* See if a given LP is active.  Allow for invalid lps to be passed in
  * and just return invalid
diff --git a/arch/powerpc/platforms/pseries/eeh.c b/arch/powerpc/platforms/pseries/eeh.c
index 7df7fbb..cb72726 100644
--- a/arch/powerpc/platforms/pseries/eeh.c
+++ b/arch/powerpc/platforms/pseries/eeh.c
@@ -1287,4 +1287,4 @@ static int __init eeh_init_proc(void)
 		proc_create("ppc64/eeh", 0, NULL, &proc_eeh_operations);
 	return 0;
 }
-__initcall(eeh_init_proc);
+device_initcall(eeh_init_proc);
diff --git a/arch/powerpc/platforms/pseries/hvCall_inst.c b/arch/powerpc/platforms/pseries/hvCall_inst.c
index 1fefae7..ca1b4e2 100644
--- a/arch/powerpc/platforms/pseries/hvCall_inst.c
+++ b/arch/powerpc/platforms/pseries/hvCall_inst.c
@@ -164,4 +164,4 @@ static int __init hcall_inst_init(void)
 
 	return 0;
 }
-__initcall(hcall_inst_init);
+device_initcall(hcall_inst_init);
diff --git a/arch/powerpc/platforms/pseries/power.c b/arch/powerpc/platforms/pseries/power.c
index 6d62662..0eafaf8 100644
--- a/arch/powerpc/platforms/pseries/power.c
+++ b/arch/powerpc/platforms/pseries/power.c
@@ -77,5 +77,5 @@ static int __init apo_pm_init(void)
 {
 	return (sysfs_create_file(power_kobj, &auto_poweron_attr.attr));
 }
-__initcall(apo_pm_init);
+device_initcall(apo_pm_init);
 #endif
diff --git a/arch/powerpc/platforms/pseries/ras.c b/arch/powerpc/platforms/pseries/ras.c
index d20b96e..247bad9 100644
--- a/arch/powerpc/platforms/pseries/ras.c
+++ b/arch/powerpc/platforms/pseries/ras.c
@@ -152,7 +152,7 @@ static int __init init_ras_IRQ(void)
 
 	return 0;
 }
-__initcall(init_ras_IRQ);
+device_initcall(init_ras_IRQ);
 
 /*
  * Handle power subsystem events (EPOW).
diff --git a/arch/powerpc/platforms/pseries/reconfig.c b/arch/powerpc/platforms/pseries/reconfig.c
index a2305d2..d82ca6c 100644
--- a/arch/powerpc/platforms/pseries/reconfig.c
+++ b/arch/powerpc/platforms/pseries/reconfig.c
@@ -557,4 +557,4 @@ static int proc_ppc64_create_ofdt(void)
 
 	return 0;
 }
-__initcall(proc_ppc64_create_ofdt);
+device_initcall(proc_ppc64_create_ofdt);
diff --git a/arch/powerpc/xmon/xmon.c b/arch/powerpc/xmon/xmon.c
index 8bad7d5..cd1ce39 100644
--- a/arch/powerpc/xmon/xmon.c
+++ b/arch/powerpc/xmon/xmon.c
@@ -2751,7 +2751,7 @@ static int __init setup_xmon_sysrq(void)
 	register_sysrq_key('x', &sysrq_xmon_op);
 	return 0;
 }
-__initcall(setup_xmon_sysrq);
+device_initcall(setup_xmon_sysrq);
 #endif /* CONFIG_MAGIC_SYSRQ */
 
 static int __initdata xmon_early, xmon_off;
diff --git a/arch/s390/appldata/appldata_base.c b/arch/s390/appldata/appldata_base.c
index 5c91995..af7ccb3 100644
--- a/arch/s390/appldata/appldata_base.c
+++ b/arch/s390/appldata/appldata_base.c
@@ -659,7 +659,7 @@ out_driver:
 	return rc;
 }
 
-__initcall(appldata_init);
+device_initcall(appldata_init);
 
 /**************************** init / exit <END> ******************************/
 
diff --git a/arch/s390/kernel/audit.c b/arch/s390/kernel/audit.c
index f4932c2..8a9023a 100644
--- a/arch/s390/kernel/audit.c
+++ b/arch/s390/kernel/audit.c
@@ -75,4 +75,4 @@ static int __init audit_classes_init(void)
 	return 0;
 }
 
-__initcall(audit_classes_init);
+device_initcall(audit_classes_init);
diff --git a/arch/s390/kernel/compat_exec_domain.c b/arch/s390/kernel/compat_exec_domain.c
index 914d494..e0715f6 100644
--- a/arch/s390/kernel/compat_exec_domain.c
+++ b/arch/s390/kernel/compat_exec_domain.c
@@ -26,4 +26,4 @@ static int __init s390_init (void)
 	return 0;
 }
 
-__initcall(s390_init);
+device_initcall(s390_init);
diff --git a/arch/s390/kernel/ipl.c b/arch/s390/kernel/ipl.c
index 7eedbbc..19906a7 100644
--- a/arch/s390/kernel/ipl.c
+++ b/arch/s390/kernel/ipl.c
@@ -1806,7 +1806,7 @@ static int __init s390_ipl_init(void)
 	return 0;
 }
 
-__initcall(s390_ipl_init);
+device_initcall(s390_ipl_init);
 
 static void __init strncpy_skip_quote(char *dst, char *src, int n)
 {
diff --git a/arch/s390/kernel/topology.c b/arch/s390/kernel/topology.c
index 14ef6f0..1a1d7ee 100644
--- a/arch/s390/kernel/topology.c
+++ b/arch/s390/kernel/topology.c
@@ -291,7 +291,7 @@ out:
 	update_cpu_core_map();
 	return rc;
 }
-__initcall(init_topology_update);
+device_initcall(init_topology_update);
 
 void __init s390_init_cpu_topology(void)
 {
diff --git a/arch/sh/boards/board-edosk7760.c b/arch/sh/boards/board-edosk7760.c
index 35dc099..f47ac82 100644
--- a/arch/sh/boards/board-edosk7760.c
+++ b/arch/sh/boards/board-edosk7760.c
@@ -182,7 +182,7 @@ static int __init init_edosk7760_devices(void)
 	return platform_add_devices(edosk7760_devices,
 				    ARRAY_SIZE(edosk7760_devices));
 }
-__initcall(init_edosk7760_devices);
+device_initcall(init_edosk7760_devices);
 
 /*
  * The Machine Vector
diff --git a/arch/sh/boards/board-sh7785lcr.c b/arch/sh/boards/board-sh7785lcr.c
index fe7e686..ee65ff0 100644
--- a/arch/sh/boards/board-sh7785lcr.c
+++ b/arch/sh/boards/board-sh7785lcr.c
@@ -284,7 +284,7 @@ static int __init sh7785lcr_devices_setup(void)
 	return platform_add_devices(sh7785lcr_devices,
 				    ARRAY_SIZE(sh7785lcr_devices));
 }
-__initcall(sh7785lcr_devices_setup);
+device_initcall(sh7785lcr_devices_setup);
 
 /* Initialize IRQ setting */
 void __init init_sh7785lcr_IRQ(void)
diff --git a/arch/sh/boards/mach-cayman/setup.c b/arch/sh/boards/mach-cayman/setup.c
index 7e8216a..e89e8e1 100644
--- a/arch/sh/boards/mach-cayman/setup.c
+++ b/arch/sh/boards/mach-cayman/setup.c
@@ -165,7 +165,7 @@ static int __init smsc_superio_setup(void)
 
 	return 0;
 }
-__initcall(smsc_superio_setup);
+device_initcall(smsc_superio_setup);
 
 static void __iomem *cayman_ioport_map(unsigned long port, unsigned int len)
 {
diff --git a/arch/sh/boards/mach-landisk/setup.c b/arch/sh/boards/mach-landisk/setup.c
index 50337ac..62f26f4 100644
--- a/arch/sh/boards/mach-landisk/setup.c
+++ b/arch/sh/boards/mach-landisk/setup.c
@@ -83,7 +83,7 @@ static int __init landisk_devices_setup(void)
 				    ARRAY_SIZE(landisk_devices));
 }
 
-__initcall(landisk_devices_setup);
+device_initcall(landisk_devices_setup);
 
 static void __init landisk_setup(char **cmdline_p)
 {
diff --git a/arch/sh/boards/mach-r2d/setup.c b/arch/sh/boards/mach-r2d/setup.c
index b84df6a..4b98a52 100644
--- a/arch/sh/boards/mach-r2d/setup.c
+++ b/arch/sh/boards/mach-r2d/setup.c
@@ -258,7 +258,7 @@ static int __init rts7751r2d_devices_setup(void)
 	return platform_add_devices(rts7751r2d_devices,
 				    ARRAY_SIZE(rts7751r2d_devices));
 }
-__initcall(rts7751r2d_devices_setup);
+device_initcall(rts7751r2d_devices_setup);
 
 static void rts7751r2d_power_off(void)
 {
diff --git a/arch/sh/boards/mach-sdk7786/setup.c b/arch/sh/boards/mach-sdk7786/setup.c
index f094ea2..ddcc73d 100644
--- a/arch/sh/boards/mach-sdk7786/setup.c
+++ b/arch/sh/boards/mach-sdk7786/setup.c
@@ -132,7 +132,7 @@ static int __init sdk7786_devices_setup(void)
 
 	return sdk7786_i2c_setup();
 }
-__initcall(sdk7786_devices_setup);
+device_initcall(sdk7786_devices_setup);
 
 static int sdk7786_mode_pins(void)
 {
diff --git a/arch/sh/boards/mach-se/7206/setup.c b/arch/sh/boards/mach-se/7206/setup.c
index 8f5c65d..91d0823 100644
--- a/arch/sh/boards/mach-se/7206/setup.c
+++ b/arch/sh/boards/mach-se/7206/setup.c
@@ -77,7 +77,7 @@ static int __init se7206_devices_setup(void)
 {
 	return platform_add_devices(se7206_devices, ARRAY_SIZE(se7206_devices));
 }
-__initcall(se7206_devices_setup);
+device_initcall(se7206_devices_setup);
 
 /*
  * The Machine Vector
diff --git a/arch/sh/boards/mach-se/7751/setup.c b/arch/sh/boards/mach-se/7751/setup.c
index 5057251..69e1479 100644
--- a/arch/sh/boards/mach-se/7751/setup.c
+++ b/arch/sh/boards/mach-se/7751/setup.c
@@ -48,7 +48,7 @@ static int __init se7751_devices_setup(void)
 {
 	return platform_add_devices(se7751_devices, ARRAY_SIZE(se7751_devices));
 }
-__initcall(se7751_devices_setup);
+device_initcall(se7751_devices_setup);
 
 /*
  * The Machine Vector
diff --git a/arch/sh/boards/mach-sh03/setup.c b/arch/sh/boards/mach-sh03/setup.c
index af4a0c0..d4f79b2 100644
--- a/arch/sh/boards/mach-sh03/setup.c
+++ b/arch/sh/boards/mach-sh03/setup.c
@@ -96,7 +96,7 @@ static int __init sh03_devices_setup(void)
 
 	return platform_add_devices(sh03_devices, ARRAY_SIZE(sh03_devices));
 }
-__initcall(sh03_devices_setup);
+device_initcall(sh03_devices_setup);
 
 static struct sh_machine_vector mv_sh03 __initmv = {
 	.mv_name		= "Interface (CTP/PCI-SH03)",
diff --git a/arch/sh/kernel/traps_64.c b/arch/sh/kernel/traps_64.c
index e3f92eb..0868d8d 100644
--- a/arch/sh/kernel/traps_64.c
+++ b/arch/sh/kernel/traps_64.c
@@ -923,7 +923,7 @@ static int __init init_sysctl(void)
 	return 0;
 }
 
-__initcall(init_sysctl);
+device_initcall(init_sysctl);
 
 
 asmlinkage void do_debug_interrupt(unsigned long code, struct pt_regs *regs)
diff --git a/arch/sparc/kernel/apc.c b/arch/sparc/kernel/apc.c
index 71ec90b..768b51b 100644
--- a/arch/sparc/kernel/apc.c
+++ b/arch/sparc/kernel/apc.c
@@ -188,4 +188,4 @@ static int __init apc_init(void)
  * and is easiest to ioremap when SBus is already
  * initialized, so we install ourselves thusly:
  */
-__initcall(apc_init);
+device_initcall(apc_init);
diff --git a/arch/sparc/kernel/audit.c b/arch/sparc/kernel/audit.c
index 8fff0ac..4be9a78 100644
--- a/arch/sparc/kernel/audit.c
+++ b/arch/sparc/kernel/audit.c
@@ -80,4 +80,4 @@ static int __init audit_classes_init(void)
 	return 0;
 }
 
-__initcall(audit_classes_init);
+device_initcall(audit_classes_init);
diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
index cdc91d9..0fb5a9c 100644
--- a/arch/sparc/kernel/mdesc.c
+++ b/arch/sparc/kernel/mdesc.c
@@ -903,7 +903,7 @@ static int __init mdesc_misc_init(void)
 	return misc_register(&mdesc_misc);
 }
 
-__initcall(mdesc_misc_init);
+device_initcall(mdesc_misc_init);
 
 void __init sun4v_mdesc_init(void)
 {
diff --git a/arch/sparc/kernel/pmc.c b/arch/sparc/kernel/pmc.c
index 5e4563d..74a99b5 100644
--- a/arch/sparc/kernel/pmc.c
+++ b/arch/sparc/kernel/pmc.c
@@ -93,4 +93,4 @@ static int __init pmc_init(void)
  * and is easiest to ioremap when SBus is already
  * initialized, so we install ourselves thusly:
  */
-__initcall(pmc_init);
+device_initcall(pmc_init);
diff --git a/arch/um/drivers/mconsole_kern.c b/arch/um/drivers/mconsole_kern.c
index de317d0..c55fa3a 100644
--- a/arch/um/drivers/mconsole_kern.c
+++ b/arch/um/drivers/mconsole_kern.c
@@ -493,7 +493,7 @@ static int __init mem_mc_init(void)
 	return 0;
 }
 
-__initcall(mem_mc_init);
+device_initcall(mem_mc_init);
 
 #define CONFIG_BUF_SIZE 64
 
@@ -816,7 +816,7 @@ static int __init mconsole_init(void)
 	return 1;
 }
 
-__initcall(mconsole_init);
+device_initcall(mconsole_init);
 
 static ssize_t mconsole_proc_write(struct file *file,
 		const char __user *buffer, size_t count, loff_t *pos)
@@ -873,7 +873,7 @@ void unlock_notify(void)
 	spin_unlock(&notify_spinlock);
 }
 
-__initcall(create_proc_mconsole);
+device_initcall(create_proc_mconsole);
 
 #define NOTIFY "notify:"
 
@@ -923,7 +923,7 @@ static int add_notifier(void)
 	return 0;
 }
 
-__initcall(add_notifier);
+device_initcall(add_notifier);
 
 char *mconsole_notify_socket(void)
 {
diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index a74245a..3864903 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -824,7 +824,7 @@ static int uml_net_init(void)
 	return 0;
 }
 
-__initcall(uml_net_init);
+device_initcall(uml_net_init);
 
 static void close_devices(void)
 {
diff --git a/arch/um/drivers/stderr_console.c b/arch/um/drivers/stderr_console.c
index d07a97f..29eb7ce 100644
--- a/arch/um/drivers/stderr_console.c
+++ b/arch/um/drivers/stderr_console.c
@@ -59,4 +59,4 @@ static int __init unregister_stderr(void)
 	return 0;
 }
 
-__initcall(unregister_stderr);
+device_initcall(unregister_stderr);
diff --git a/arch/um/drivers/ubd_kern.c b/arch/um/drivers/ubd_kern.c
index c1ff690..d5de090 100644
--- a/arch/um/drivers/ubd_kern.c
+++ b/arch/um/drivers/ubd_kern.c
@@ -1010,7 +1010,7 @@ static int __init ubd_mc_init(void)
 	return 0;
 }
 
-__initcall(ubd_mc_init);
+device_initcall(ubd_mc_init);
 
 static int __init ubd0_init(void)
 {
@@ -1024,7 +1024,7 @@ static int __init ubd0_init(void)
 	return 0;
 }
 
-__initcall(ubd0_init);
+device_initcall(ubd0_init);
 
 /* Used in ubd_init, which is an initcall */
 static struct platform_driver ubd_driver = {
diff --git a/arch/um/kernel/exitcode.c b/arch/um/kernel/exitcode.c
index 829df49..cb05ff8 100644
--- a/arch/um/kernel/exitcode.c
+++ b/arch/um/kernel/exitcode.c
@@ -75,4 +75,4 @@ static int make_proc_exitcode(void)
 	return 0;
 }
 
-__initcall(make_proc_exitcode);
+device_initcall(make_proc_exitcode);
diff --git a/arch/um/kernel/physmem.c b/arch/um/kernel/physmem.c
index a1a9090..87537f0 100644
--- a/arch/um/kernel/physmem.c
+++ b/arch/um/kernel/physmem.c
@@ -209,4 +209,4 @@ static int setup_iomem(void)
 	return 0;
 }
 
-__initcall(setup_iomem);
+device_initcall(setup_iomem);
diff --git a/arch/um/os-Linux/aio.c b/arch/um/os-Linux/aio.c
index 57e3d46..337437e 100644
--- a/arch/um/os-Linux/aio.c
+++ b/arch/um/os-Linux/aio.c
@@ -343,13 +343,13 @@ static int init_aio(void)
 }
 
 /*
- * The reason for the __initcall/__uml_exitcall asymmetry is that init_aio
+ * The reason for the device_initcall/__uml_exitcall asymmetry is that init_aio
  * needs to be called when the kernel is running because it calls run_helper,
  * which needs get_free_page.  exit_aio is a __uml_exitcall because the generic
  * kernel does not run __exitcalls on shutdown, and can't because many of them
  * break when called outside of module unloading.
  */
-__initcall(init_aio);
+device_initcall(init_aio);
 
 static void exit_aio(void)
 {
diff --git a/arch/um/os-Linux/skas/mem.c b/arch/um/os-Linux/skas/mem.c
index d261f17..a0a816a 100644
--- a/arch/um/os-Linux/skas/mem.c
+++ b/arch/um/os-Linux/skas/mem.c
@@ -46,7 +46,7 @@ static int __init init_syscall_regs(void)
 	return 0;
 }
 
-__initcall(init_syscall_regs);
+device_initcall(init_syscall_regs);
 
 extern int proc_mm;
 
diff --git a/arch/um/os-Linux/skas/process.c b/arch/um/os-Linux/skas/process.c
index d6e0a22..25ef142 100644
--- a/arch/um/os-Linux/skas/process.c
+++ b/arch/um/os-Linux/skas/process.c
@@ -473,7 +473,7 @@ static int __init init_thread_regs(void)
 	return 0;
 }
 
-__initcall(init_thread_regs);
+device_initcall(init_thread_regs);
 
 int copy_context_skas0(unsigned long new_stack, int pid)
 {
diff --git a/arch/um/os-Linux/umid.c b/arch/um/os-Linux/umid.c
index a27defb..23f7b37 100644
--- a/arch/um/os-Linux/umid.c
+++ b/arch/um/os-Linux/umid.c
@@ -326,7 +326,7 @@ static int __init make_umid_init(void)
 	return 0;
 }
 
-__initcall(make_umid_init);
+device_initcall(make_umid_init);
 
 int __init umid_file_name(char *name, char *buf, int len)
 {
diff --git a/arch/um/sys-i386/tls.c b/arch/um/sys-i386/tls.c
index c6c7131..b285fd7 100644
--- a/arch/um/sys-i386/tls.c
+++ b/arch/um/sys-i386/tls.c
@@ -393,4 +393,4 @@ static int __init __setup_host_supports_tls(void)
 	return 0;
 }
 
-__initcall(__setup_host_supports_tls);
+device_initcall(__setup_host_supports_tls);
diff --git a/arch/x86/kernel/audit_64.c b/arch/x86/kernel/audit_64.c
index 06d3e5a..bab6ddc 100644
--- a/arch/x86/kernel/audit_64.c
+++ b/arch/x86/kernel/audit_64.c
@@ -78,4 +78,4 @@ static int __init audit_classes_init(void)
 	return 0;
 }
 
-__initcall(audit_classes_init);
+device_initcall(audit_classes_init);
diff --git a/arch/x86/kernel/tlb_uv.c b/arch/x86/kernel/tlb_uv.c
index 364d015..eb71685 100644
--- a/arch/x86/kernel/tlb_uv.c
+++ b/arch/x86/kernel/tlb_uv.c
@@ -860,5 +860,5 @@ static int __init uv_bau_init(void)
 
 	return 0;
 }
-__initcall(uv_bau_init);
-__initcall(uv_ptc_init);
+device_initcall(uv_bau_init);
+device_initcall(uv_ptc_init);
diff --git a/arch/x86/kernel/vsyscall_64.c b/arch/x86/kernel/vsyscall_64.c
index 1c0c6ab..df45aaf 100644
--- a/arch/x86/kernel/vsyscall_64.c
+++ b/arch/x86/kernel/vsyscall_64.c
@@ -244,7 +244,7 @@ static ctl_table kernel_root_table2[] = {
 };
 #endif
 
-/* Assume __initcall executes before all user space. Hopefully kmod
+/* Assume device_initcall executes before all user space. Hopefully kmod
    doesn't violate that. We'll find out if it does. */
 static void __cpuinit vsyscall_set_cpu(int cpu)
 {
@@ -306,4 +306,4 @@ static int __init vsyscall_init(void)
 	return 0;
 }
 
-__initcall(vsyscall_init);
+device_initcall(vsyscall_init);
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index a725b7f..a84535d 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -349,7 +349,7 @@ static int pt_dump_init(void)
 	return 0;
 }
 
-__initcall(pt_dump_init);
+device_initcall(pt_dump_init);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arjan van de Ven <arjan@linux.intel.com>");
 MODULE_DESCRIPTION("Kernel debugging helper that dumps pagetables");
diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index 02b442e..6c73b85 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -374,7 +374,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 
 #ifdef CONFIG_X86_64
 
-__initcall(sysenter_setup);
+device_initcall(sysenter_setup);
 
 #ifdef CONFIG_SYSCTL
 /* Register vsyscall32 into the ABI table */
@@ -405,7 +405,7 @@ static __init int ia32_binfmt_init(void)
 	register_sysctl_table(abi_root_table2);
 	return 0;
 }
-__initcall(ia32_binfmt_init);
+device_initcall(ia32_binfmt_init);
 #endif
 
 #else  /* CONFIG_X86_32 */
diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index 21e1aeb..860addc 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -73,7 +73,7 @@ static int __init init_vdso_vars(void)
 	vdso_enabled = 0;
 	return -ENOMEM;
 }
-__initcall(init_vdso_vars);
+device_initcall(init_vdso_vars);
 
 struct linux_binprm;
 
diff --git a/arch/xtensa/platforms/iss/console.c b/arch/xtensa/platforms/iss/console.c
index e60a1f5..cdf1715 100644
--- a/arch/xtensa/platforms/iss/console.c
+++ b/arch/xtensa/platforms/iss/console.c
@@ -248,7 +248,7 @@ static __exit void rs_exit(void)
 }
 
 
-/* We use `late_initcall' instead of just `__initcall' as a workaround for
+/* We use `late_initcall' instead of just `device_initcall' as a workaround for
  * the fact that (1) simcons_tty_init can't be called before tty_init,
  * (2) tty_init is called via `module_init', (3) if statically linked,
  * module_init == device_init, and (4) there's no ordering of init lists.
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index f1f58c5..cc2c734 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -775,4 +775,4 @@ static int __init am79c961_init(void)
 	return platform_driver_register(&am79c961_driver);
 }
 
-__initcall(am79c961_init);
+device_initcall(am79c961_init);
diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index a3c0dc9..fc6f80e 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -35,6 +35,7 @@
  *                    removed some pre-2.2 kernel compatibility cruft
  *   0.6  10.08.1999  Check if parport can do SPP and is safe to access during interrupt contexts
  *   0.7  12.02.2000  adapted to softnet driver interface
+ *   0.8  03.18.2010  update deprecated __initcall to device_initcall
  *
  */
 
diff --git a/drivers/net/hamradio/baycom_par.c b/drivers/net/hamradio/baycom_par.c
index 5f5af9a..f2ddffa 100644
--- a/drivers/net/hamradio/baycom_par.c
+++ b/drivers/net/hamradio/baycom_par.c
@@ -64,6 +64,7 @@
  *   0.8  12.02.2000  adapted to softnet driver interface
  *                    removed direct parport access, uses parport driver methods
  *   0.9  03.07.2000  fix interface name handling
+ *   0.10 03.18.2010  update deprecated __initcall to device_initcall
  */
 
 /*****************************************************************************/
diff --git a/drivers/net/hamradio/baycom_ser_fdx.c b/drivers/net/hamradio/baycom_ser_fdx.c
index 0cab992..d90ad93 100644
--- a/drivers/net/hamradio/baycom_ser_fdx.c
+++ b/drivers/net/hamradio/baycom_ser_fdx.c
@@ -67,6 +67,7 @@
  *   0.8  10.08.1999  use module_init/module_exit
  *   0.9  12.02.2000  adapted to softnet driver interface
  *   0.10 03.07.2000  fix interface name handling
+ *   0.11 03.18.2010  update deprecated __initcall to device_initcall
  */
 
 /*****************************************************************************/
diff --git a/drivers/net/hamradio/baycom_ser_hdx.c b/drivers/net/hamradio/baycom_ser_hdx.c
index 1686f6d..3033cae 100644
--- a/drivers/net/hamradio/baycom_ser_hdx.c
+++ b/drivers/net/hamradio/baycom_ser_hdx.c
@@ -57,6 +57,7 @@
  *   0.8  10.08.1999  use module_init/module_exit
  *   0.9  12.02.2000  adapted to softnet driver interface
  *   0.10 03.07.2000  fix interface name handling
+ *   0.11 03.18.2010  update deprecated __initcall to device_initcall
  */
 
 /*****************************************************************************/
diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
index b3beab6..642b3bf 100644
--- a/drivers/s390/char/sclp_cmd.c
+++ b/drivers/s390/char/sclp_cmd.c
@@ -628,7 +628,7 @@ out:
 	free_page((unsigned long) sccb);
 	return rc;
 }
-__initcall(sclp_detect_standby_memory);
+device_initcall(sclp_detect_standby_memory);
 
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
diff --git a/drivers/s390/char/sclp_config.c b/drivers/s390/char/sclp_config.c
index b497afe..c257eb3 100644
--- a/drivers/s390/char/sclp_config.c
+++ b/drivers/s390/char/sclp_config.c
@@ -87,4 +87,4 @@ static int __init sclp_conf_init(void)
 	return rc;
 }
 
-__initcall(sclp_conf_init);
+device_initcall(sclp_conf_init);
diff --git a/drivers/s390/char/sclp_cpi_sys.c b/drivers/s390/char/sclp_cpi_sys.c
index 62c2647..1ebb83c 100644
--- a/drivers/s390/char/sclp_cpi_sys.c
+++ b/drivers/s390/char/sclp_cpi_sys.c
@@ -426,4 +426,4 @@ static int __init cpi_init(void)
 	return rc;
 }
 
-__initcall(cpi_init);
+device_initcall(cpi_init);
diff --git a/drivers/s390/char/sclp_vt220.c b/drivers/s390/char/sclp_vt220.c
index 3796ffd..deff553 100644
--- a/drivers/s390/char/sclp_vt220.c
+++ b/drivers/s390/char/sclp_vt220.c
@@ -707,7 +707,7 @@ out_driver:
 	put_tty_driver(driver);
 	return rc;
 }
-__initcall(sclp_vt220_tty_init);
+device_initcall(sclp_vt220_tty_init);
 
 static void __sclp_vt220_flush_buffer(void)
 {
diff --git a/drivers/s390/cio/blacklist.c b/drivers/s390/cio/blacklist.c
index 7eab9ab..363fd02 100644
--- a/drivers/s390/cio/blacklist.c
+++ b/drivers/s390/cio/blacklist.c
@@ -398,6 +398,6 @@ cio_ignore_proc_init (void)
 	return 0;
 }
 
-__initcall (cio_ignore_proc_init);
+device_initcall(cio_ignore_proc_init);
 
 #endif /* CONFIG_PROC_FS */
diff --git a/drivers/staging/rtl8192u/ieee80211/api.c b/drivers/staging/rtl8192u/ieee80211/api.c
index c627d02..156d867 100644
--- a/drivers/staging/rtl8192u/ieee80211/api.c
+++ b/drivers/staging/rtl8192u/ieee80211/api.c
@@ -229,7 +229,7 @@ static int __init init_crypto(void)
 	return 0;
 }
 
-__initcall(init_crypto);
+device_initcall(init_crypto);
 
 /*
 EXPORT_SYMBOL_GPL(crypto_register_alg);
diff --git a/fs/aio.c b/fs/aio.c
index 1cf12b3..80ddf44 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -92,7 +92,7 @@ static int __init aio_setup(void)
 
 	return 0;
 }
-__initcall(aio_setup);
+device_initcall(aio_setup);
 
 static void aio_free_ring(struct kioctx *ctx)
 {
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 6d55b61..b579a82 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -1780,4 +1780,4 @@ static int __init init_sys32_ioctl(void)
 		init_sys32_ioctl_cmp, NULL);
 	return 0;
 }
-__initcall(init_sys32_ioctl);
+device_initcall(init_sys32_ioctl);
diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
index 56410fa..3d59d44 100644
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -209,4 +209,4 @@ static int __init ipc_sysctl_init(void)
 	return 0;
 }
 
-__initcall(ipc_sysctl_init);
+device_initcall(ipc_sysctl_init);
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index e4e3f04..c58ca57 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -1322,4 +1322,4 @@ out_sysctl:
 	return error;
 }
 
-__initcall(init_mqueue_fs);
+device_initcall(init_mqueue_fs);
diff --git a/ipc/util.c b/ipc/util.c
index 79ce84e..d82ec6c 100644
--- a/ipc/util.c
+++ b/ipc/util.c
@@ -106,7 +106,7 @@ static int __init ipc_init(void)
 	register_ipcns_notifier(&init_ipc_ns);
 	return 0;
 }
-__initcall(ipc_init);
+device_initcall(ipc_init);
 
 /**
  *	ipc_init_ids		-	initialise IPC identifiers
diff --git a/kernel/audit.c b/kernel/audit.c
index 78f7f86..d489f47 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -989,7 +989,7 @@ static int __init audit_init(void)
 
 	return 0;
 }
-__initcall(audit_init);
+device_initcall(audit_init);
 
 /* Process kernel command-line parameter at boot time.  audit=0 or audit=1. */
 static int __init audit_enable(char *str)
diff --git a/kernel/audit_tree.c b/kernel/audit_tree.c
index 028e856..e54d2c6 100644
--- a/kernel/audit_tree.c
+++ b/kernel/audit_tree.c
@@ -919,4 +919,4 @@ static int __init audit_tree_init(void)
 
 	return 0;
 }
-__initcall(audit_tree_init);
+device_initcall(audit_tree_init);
diff --git a/kernel/dma.c b/kernel/dma.c
index f903189..b54e161 100644
--- a/kernel/dma.c
+++ b/kernel/dma.c
@@ -153,7 +153,7 @@ static int __init proc_dma_init(void)
 	return 0;
 }
 
-__initcall(proc_dma_init);
+device_initcall(proc_dma_init);
 #endif
 
 EXPORT_SYMBOL(request_dma);
diff --git a/kernel/futex.c b/kernel/futex.c
index e7a35f1..94efb8c 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -2670,4 +2670,4 @@ static int __init futex_init(void)
 
 	return 0;
 }
-__initcall(futex_init);
+device_initcall(futex_init);
diff --git a/kernel/lockdep_proc.c b/kernel/lockdep_proc.c
index d4aba4f..a4088c9 100644
--- a/kernel/lockdep_proc.c
+++ b/kernel/lockdep_proc.c
@@ -687,5 +687,5 @@ static int __init lockdep_proc_init(void)
 	return 0;
 }
 
-__initcall(lockdep_proc_init);
+device_initcall(lockdep_proc_init);
 
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 79aac93..2c7b5e7 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -189,4 +189,4 @@ static __init int pid_namespaces_init(void)
 	return 0;
 }
 
-__initcall(pid_namespaces_init);
+device_initcall(pid_namespaces_init);
diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
index 1a22dfd..036d64e 100644
--- a/kernel/posix-cpu-timers.c
+++ b/kernel/posix-cpu-timers.c
@@ -1727,4 +1727,4 @@ static __init int init_posix_cpu_timers(void)
 
 	return 0;
 }
-__initcall(init_posix_cpu_timers);
+device_initcall(init_posix_cpu_timers);
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 00d1fda..e8c2d04 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -309,7 +309,7 @@ static __init int init_posix_timers(void)
 	return 0;
 }
 
-__initcall(init_posix_timers);
+device_initcall(init_posix_timers);
 
 static void schedule_next_timer(struct k_itimer *timr)
 {
diff --git a/kernel/resource.c b/kernel/resource.c
index 2d5be5d..e678177 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -136,7 +136,7 @@ static int __init ioresources_init(void)
 	proc_create("iomem", 0, NULL, &proc_iomem_operations);
 	return 0;
 }
-__initcall(ioresources_init);
+device_initcall(ioresources_init);
 
 #endif /* CONFIG_PROC_FS */
 
diff --git a/kernel/sched_debug.c b/kernel/sched_debug.c
index 67f95aa..c17988b 100644
--- a/kernel/sched_debug.c
+++ b/kernel/sched_debug.c
@@ -379,7 +379,7 @@ static int __init init_sched_debug_procfs(void)
 	return 0;
 }
 
-__initcall(init_sched_debug_procfs);
+device_initcall(init_sched_debug_procfs);
 
 void proc_sched_show_task(struct task_struct *p, struct seq_file *m)
 {
diff --git a/kernel/time/timer_list.c b/kernel/time/timer_list.c
index bdfb8dd..962b3b2 100644
--- a/kernel/time/timer_list.c
+++ b/kernel/time/timer_list.c
@@ -296,4 +296,4 @@ static int __init init_timer_list_procfs(void)
 		return -ENOMEM;
 	return 0;
 }
-__initcall(init_timer_list_procfs);
+device_initcall(init_timer_list_procfs);
diff --git a/kernel/time/timer_stats.c b/kernel/time/timer_stats.c
index 2f3b585..517552b 100644
--- a/kernel/time/timer_stats.c
+++ b/kernel/time/timer_stats.c
@@ -422,4 +422,4 @@ static int __init init_tstats_procfs(void)
 		return -ENOMEM;
 	return 0;
 }
-__initcall(init_tstats_procfs);
+device_initcall(init_tstats_procfs);
diff --git a/kernel/tracepoint.c b/kernel/tracepoint.c
index cc89be5..c4d12e8 100644
--- a/kernel/tracepoint.c
+++ b/kernel/tracepoint.c
@@ -580,7 +580,7 @@ static int init_tracepoints(void)
 {
 	return register_module_notifier(&tracepoint_module_nb);
 }
-__initcall(init_tracepoints);
+device_initcall(init_tracepoints);
 
 #endif /* CONFIG_MODULES */
 
diff --git a/kernel/utsname_sysctl.c b/kernel/utsname_sysctl.c
index a2cd77e..7cbb001 100644
--- a/kernel/utsname_sysctl.c
+++ b/kernel/utsname_sysctl.c
@@ -111,4 +111,4 @@ static int __init utsname_sysctl_init(void)
 	return 0;
 }
 
-__initcall(utsname_sysctl_init);
+device_initcall(utsname_sysctl_init);
diff --git a/lib/audit.c b/lib/audit.c
index 8e7dc1c..26f41a9 100644
--- a/lib/audit.c
+++ b/lib/audit.c
@@ -63,4 +63,4 @@ static int __init audit_classes_init(void)
 	return 0;
 }
 
-__initcall(audit_classes_init);
+device_initcall(audit_classes_init);
diff --git a/lib/debugobjects.c b/lib/debugobjects.c
index a9a8996..ee41495 100644
--- a/lib/debugobjects.c
+++ b/lib/debugobjects.c
@@ -666,7 +666,7 @@ err:
 
 	return -ENOMEM;
 }
-__initcall(debug_objects_init_debugfs);
+device_initcall(debug_objects_init_debugfs);
 
 #else
 static inline void debug_objects_init_debugfs(void) { }
diff --git a/mm/bounce.c b/mm/bounce.c
index a2b76a5..b6df140 100644
--- a/mm/bounce.c
+++ b/mm/bounce.c
@@ -39,7 +39,7 @@ static __init int init_emergency_pool(void)
 	return 0;
 }
 
-__initcall(init_emergency_pool);
+device_initcall(init_emergency_pool);
 
 /*
  * highmem version, map in to vec
diff --git a/mm/memory.c b/mm/memory.c
index 5b7f200..b39f34e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3231,7 +3231,7 @@ static int __init gate_vma_init(void)
 	gate_vma.vm_flags |= VM_ALWAYSDUMP;
 	return 0;
 }
-__initcall(gate_vma_init);
+device_initcall(gate_vma_init);
 #endif
 
 struct vm_area_struct *get_gate_vma(struct task_struct *tsk)
diff --git a/mm/mm_init.c b/mm/mm_init.c
index 4e0e265..6586ce5 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -149,4 +149,4 @@ static int __init mm_sysfs_init(void)
 	return 0;
 }
 
-__initcall(mm_sysfs_init);
+device_initcall(mm_sysfs_init);
diff --git a/mm/slab.c b/mm/slab.c
index a9f325b..891218c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1597,7 +1597,7 @@ static int __init cpucache_init(void)
 		start_cpu_timer(cpu);
 	return 0;
 }
-__initcall(cpucache_init);
+device_initcall(cpucache_init);
 
 /*
  * Interface to system's page allocator. No need to hold the cache-lock.
diff --git a/mm/slub.c b/mm/slub.c
index b364844..a048aa5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4577,7 +4577,7 @@ static int __init slab_sysfs_init(void)
 	return 0;
 }
 
-__initcall(slab_sysfs_init);
+device_initcall(slab_sysfs_init);
 #endif
 
 /*
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6cd0a8f..c1e2b6d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1764,7 +1764,7 @@ static int __init procswaps_init(void)
 	proc_create("swaps", 0, NULL, &proc_swaps_operations);
 	return 0;
 }
-__initcall(procswaps_init);
+device_initcall(procswaps_init);
 #endif /* CONFIG_PROC_FS */
 
 #ifdef MAX_SWAPFILES_CHECK
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 5c24db4..5bdd7d2 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -32,7 +32,7 @@ static __init int init_syncookies(void)
 	get_random_bytes(syncookie_secret, sizeof(syncookie_secret));
 	return 0;
 }
-__initcall(init_syncookies);
+device_initcall(init_syncookies);
 
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c1bc074..6e61075 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -748,4 +748,4 @@ static __init int sysctl_ipv4_init(void)
 	return 0;
 }
 
-__initcall(sysctl_ipv4_init);
+device_initcall(sysctl_ipv4_init);
diff --git a/security/keys/proc.c b/security/keys/proc.c
index 9d01021..9412316 100644
--- a/security/keys/proc.c
+++ b/security/keys/proc.c
@@ -83,7 +83,7 @@ static int __init key_proc_init(void)
 
 } /* end key_proc_init() */
 
-__initcall(key_proc_init);
+device_initcall(key_proc_init);
 
 /*****************************************************************************/
 /*
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5feecb4..db02af5 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -5783,7 +5783,7 @@ out:
 	return err;
 }
 
-__initcall(selinux_nf_ip_init);
+device_initcall(selinux_nf_ip_init);
 
 #ifdef CONFIG_SECURITY_SELINUX_DISABLE
 static void selinux_nf_ip_exit(void)
diff --git a/security/selinux/netif.c b/security/selinux/netif.c
index b4e14bc..9f89a94 100644
--- a/security/selinux/netif.c
+++ b/security/selinux/netif.c
@@ -315,5 +315,5 @@ static __init int sel_netif_init(void)
 	return err;
 }
 
-__initcall(sel_netif_init);
+device_initcall(sel_netif_init);
 
diff --git a/security/selinux/netlink.c b/security/selinux/netlink.c
index 1ae5564..403b707 100644
--- a/security/selinux/netlink.c
+++ b/security/selinux/netlink.c
@@ -113,4 +113,4 @@ static int __init selnl_init(void)
 	return 0;
 }
 
-__initcall(selnl_init);
+device_initcall(selnl_init);
diff --git a/security/selinux/netnode.c b/security/selinux/netnode.c
index 7100072..e7ae484 100644
--- a/security/selinux/netnode.c
+++ b/security/selinux/netnode.c
@@ -344,4 +344,4 @@ static __init int sel_netnode_init(void)
 	return ret;
 }
 
-__initcall(sel_netnode_init);
+device_initcall(sel_netnode_init);
diff --git a/security/selinux/netport.c b/security/selinux/netport.c
index fe7fba6..94c29f4 100644
--- a/security/selinux/netport.c
+++ b/security/selinux/netport.c
@@ -278,4 +278,4 @@ static __init int sel_netport_init(void)
 	return ret;
 }
 
-__initcall(sel_netport_init);
+device_initcall(sel_netport_init);
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index cd191bb..03eb7d8 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -1730,7 +1730,7 @@ static int __init init_sel_fs(void)
 	return err;
 }
 
-__initcall(init_sel_fs);
+device_initcall(init_sel_fs);
 
 #ifdef CONFIG_SECURITY_SELINUX_DISABLE
 void exit_sel_fs(void)
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index cf27b3e..e7eb598 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -2964,7 +2964,7 @@ static int __init aurule_init(void)
 
 	return err;
 }
-__initcall(aurule_init);
+device_initcall(aurule_init);
 
 #ifdef CONFIG_NETLABEL
 /**
diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index aeead75..8faf43e 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -1366,4 +1366,4 @@ static int __init init_smk_fs(void)
 	return err;
 }
 
-__initcall(init_smk_fs);
+device_initcall(init_smk_fs);
diff --git a/sound/last.c b/sound/last.c
index bdd0857..5efc26a 100644
--- a/sound/last.c
+++ b/sound/last.c
@@ -38,4 +38,4 @@ static int __init alsa_sound_last_init(void)
 	return 0;
 }
 
-__initcall(alsa_sound_last_init);
+device_initcall(alsa_sound_last_init);
-- 
1.6.5.GIT

