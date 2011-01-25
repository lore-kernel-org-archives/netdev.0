From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 13/20] appletalk: move to staging
Date: Tue, 25 Jan 2011 23:17:27 +0100
Message-ID: <1295993854-4971-14-git-send-email-arnd@arndb.de>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295993854-4971-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For all I know, Appletalk is dead, the only reasonable
use right now would be nostalgia, and that can be served
well enough by old kernels. The code is largely not
in a bad shape, but it still uses the big kernel lock,
and nobody seems motivated to change that.

FWIW, the last release of MacOS that supported Appletalk
was MacOS X 10.5, made in 2007, and it has been abandoned
by Apple with 10.6. Using TCP/IP instead of Appletalk has
been supported since MacOS 7.6, which was released in
1997 and is able to run on most of the legacy hardware.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: netdev@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@suse.de>
---
 MAINTAINERS                                        |    3 +--
 drivers/net/Makefile                               |    1 -
 drivers/net/appletalk/Makefile                     |    7 -------
 drivers/staging/Kconfig                            |    2 ++
 drivers/staging/Makefile                           |    1 +
 drivers/{net => staging}/appletalk/Kconfig         |    0
 {net => drivers/staging}/appletalk/Makefile        |    7 +++++--
 {net => drivers/staging}/appletalk/aarp.c          |    2 +-
 .../linux => drivers/staging/appletalk}/atalk.h    |    0
 {net => drivers/staging}/appletalk/atalk_proc.c    |    2 +-
 drivers/{net => staging}/appletalk/cops.c          |    2 +-
 drivers/{net => staging}/appletalk/cops.h          |    0
 drivers/{net => staging}/appletalk/cops_ffdrv.h    |    0
 drivers/{net => staging}/appletalk/cops_ltdrv.h    |    0
 {net => drivers/staging}/appletalk/ddp.c           |    4 ++--
 {net => drivers/staging}/appletalk/dev.c           |    0
 drivers/{net => staging}/appletalk/ipddp.c         |    2 +-
 drivers/{net => staging}/appletalk/ipddp.h         |    0
 drivers/{net => staging}/appletalk/ltpc.c          |    2 +-
 drivers/{net => staging}/appletalk/ltpc.h          |    0
 .../staging}/appletalk/sysctl_net_atalk.c          |    2 +-
 fs/compat_ioctl.c                                  |    1 -
 include/linux/Kbuild                               |    1 -
 net/Kconfig                                        |    1 -
 net/Makefile                                       |    1 -
 net/socket.c                                       |    1 -
 26 files changed, 17 insertions(+), 25 deletions(-)
 delete mode 100644 drivers/net/appletalk/Makefile
 rename drivers/{net => staging}/appletalk/Kconfig (100%)
 rename {net => drivers/staging}/appletalk/Makefile (56%)
 rename {net => drivers/staging}/appletalk/aarp.c (99%)
 rename {include/linux => drivers/staging/appletalk}/atalk.h (100%)
 rename {net => drivers/staging}/appletalk/atalk_proc.c (99%)
 rename drivers/{net => staging}/appletalk/cops.c (99%)
 rename drivers/{net => staging}/appletalk/cops.h (100%)
 rename drivers/{net => staging}/appletalk/cops_ffdrv.h (100%)
 rename drivers/{net => staging}/appletalk/cops_ltdrv.h (100%)
 rename {net => drivers/staging}/appletalk/ddp.c (99%)
 rename {net => drivers/staging}/appletalk/dev.c (100%)
 rename drivers/{net => staging}/appletalk/ipddp.c (99%)
 rename drivers/{net => staging}/appletalk/ipddp.h (100%)
 rename drivers/{net => staging}/appletalk/ltpc.c (99%)
 rename drivers/{net => staging}/appletalk/ltpc.h (100%)
 rename {net => drivers/staging}/appletalk/sysctl_net_atalk.c (98%)

diff --git a/MAINTAINERS b/MAINTAINERS
index fe5ca5f..5021051 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -554,8 +554,7 @@ F:	drivers/hwmon/applesmc.c
 APPLETALK NETWORK LAYER
 M:	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
 S:	Maintained
-F:	drivers/net/appletalk/
-F:	net/appletalk/
+F:	drivers/staging/appletalk/
 
 ARC FRAMEBUFFER DRIVER
 M:	Jaya Kumar <jayalk@intworks.biz>
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b90738d..11a9c05 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -265,7 +265,6 @@ obj-$(CONFIG_MACB) += macb.o
 obj-$(CONFIG_S6GMAC) += s6gmac.o
 
 obj-$(CONFIG_ARM) += arm/
-obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
 obj-$(CONFIG_ARCNET) += arcnet/
diff --git a/drivers/net/appletalk/Makefile b/drivers/net/appletalk/Makefile
deleted file mode 100644
index 6cfc705..0000000
--- a/drivers/net/appletalk/Makefile
+++ /dev/null
@@ -1,7 +0,0 @@
-#
-# Makefile for drivers/net/appletalk
-#
-
-obj-$(CONFIG_IPDDP) += ipddp.o
-obj-$(CONFIG_COPS) += cops.o
-obj-$(CONFIG_LTPC) += ltpc.o
diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 9fc5aa6..04514b5 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -167,6 +167,8 @@ source "drivers/staging/bcm/Kconfig"
 
 source "drivers/staging/ft1000/Kconfig"
 
+source "drivers/staging/appletalk/Kconfig"
+
 source "drivers/staging/intel_sst/Kconfig"
 
 source "drivers/staging/speakup/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 878f381..0ec94e8 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -64,6 +64,7 @@ obj-$(CONFIG_ATH6K_LEGACY)	+= ath6kl/
 obj-$(CONFIG_USB_ENESTORAGE)	+= keucr/
 obj-$(CONFIG_BCM_WIMAX)	+= bcm/
 obj-$(CONFIG_FT1000)		+= ft1000/
+obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_SND_INTEL_SST)		+= intel_sst/
 obj-$(CONFIG_SPEAKUP)	+= speakup/
 obj-$(CONFIG_TOUCHSCREEN_CLEARPAD_TM1217)	+= cptm1217/
diff --git a/drivers/net/appletalk/Kconfig b/drivers/staging/appletalk/Kconfig
similarity index 100%
rename from drivers/net/appletalk/Kconfig
rename to drivers/staging/appletalk/Kconfig
diff --git a/net/appletalk/Makefile b/drivers/staging/appletalk/Makefile
similarity index 56%
rename from net/appletalk/Makefile
rename to drivers/staging/appletalk/Makefile
index 5cda56e..2a5129a 100644
--- a/net/appletalk/Makefile
+++ b/drivers/staging/appletalk/Makefile
@@ -1,9 +1,12 @@
 #
-# Makefile for the Linux AppleTalk layer.
+# Makefile for drivers/staging/appletalk
 #
-
 obj-$(CONFIG_ATALK) += appletalk.o
 
 appletalk-y			:= aarp.o ddp.o dev.o
 appletalk-$(CONFIG_PROC_FS)	+= atalk_proc.o
 appletalk-$(CONFIG_SYSCTL)	+= sysctl_net_atalk.o
+
+obj-$(CONFIG_IPDDP) += ipddp.o
+obj-$(CONFIG_COPS) += cops.o
+obj-$(CONFIG_LTPC) += ltpc.o
diff --git a/net/appletalk/aarp.c b/drivers/staging/appletalk/aarp.c
similarity index 99%
rename from net/appletalk/aarp.c
rename to drivers/staging/appletalk/aarp.c
index 50dce79..7163a1d 100644
--- a/net/appletalk/aarp.c
+++ b/drivers/staging/appletalk/aarp.c
@@ -34,7 +34,7 @@
 #include <net/sock.h>
 #include <net/datalink.h>
 #include <net/psnap.h>
-#include <linux/atalk.h>
+#include "atalk.h"
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
diff --git a/include/linux/atalk.h b/drivers/staging/appletalk/atalk.h
similarity index 100%
rename from include/linux/atalk.h
rename to drivers/staging/appletalk/atalk.h
diff --git a/net/appletalk/atalk_proc.c b/drivers/staging/appletalk/atalk_proc.c
similarity index 99%
rename from net/appletalk/atalk_proc.c
rename to drivers/staging/appletalk/atalk_proc.c
index 6ef0e76..d012ba2 100644
--- a/net/appletalk/atalk_proc.c
+++ b/drivers/staging/appletalk/atalk_proc.c
@@ -13,7 +13,7 @@
 #include <linux/seq_file.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
-#include <linux/atalk.h>
+#include "atalk.h"
 
 
 static __inline__ struct atalk_iface *atalk_get_interface_idx(loff_t pos)
diff --git a/drivers/net/appletalk/cops.c b/drivers/staging/appletalk/cops.c
similarity index 99%
rename from drivers/net/appletalk/cops.c
rename to drivers/staging/appletalk/cops.c
index 748c9f5..661d42e 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/staging/appletalk/cops.c
@@ -65,7 +65,6 @@ static const char *version =
 #include <linux/if_arp.h>
 #include <linux/if_ltalk.h>
 #include <linux/delay.h>	/* For udelay() */
-#include <linux/atalk.h>
 #include <linux/spinlock.h>
 #include <linux/bitops.h>
 #include <linux/jiffies.h>
@@ -74,6 +73,7 @@ static const char *version =
 #include <asm/io.h>
 #include <asm/dma.h>
 
+#include "atalk.h"
 #include "cops.h"		/* Our Stuff */
 #include "cops_ltdrv.h"		/* Firmware code for Tangent type cards. */
 #include "cops_ffdrv.h"		/* Firmware code for Dayna type cards. */
diff --git a/drivers/net/appletalk/cops.h b/drivers/staging/appletalk/cops.h
similarity index 100%
rename from drivers/net/appletalk/cops.h
rename to drivers/staging/appletalk/cops.h
diff --git a/drivers/net/appletalk/cops_ffdrv.h b/drivers/staging/appletalk/cops_ffdrv.h
similarity index 100%
rename from drivers/net/appletalk/cops_ffdrv.h
rename to drivers/staging/appletalk/cops_ffdrv.h
diff --git a/drivers/net/appletalk/cops_ltdrv.h b/drivers/staging/appletalk/cops_ltdrv.h
similarity index 100%
rename from drivers/net/appletalk/cops_ltdrv.h
rename to drivers/staging/appletalk/cops_ltdrv.h
diff --git a/net/appletalk/ddp.c b/drivers/staging/appletalk/ddp.c
similarity index 99%
rename from net/appletalk/ddp.c
rename to drivers/staging/appletalk/ddp.c
index c410b93..940dd19 100644
--- a/net/appletalk/ddp.c
+++ b/drivers/staging/appletalk/ddp.c
@@ -63,8 +63,8 @@
 #include <net/sock.h>
 #include <net/tcp_states.h>
 #include <net/route.h>
-#include <linux/atalk.h>
-#include "../core/kmap_skb.h"
+#include "atalk.h"
+#include "../../net/core/kmap_skb.h"
 
 struct datalink_proto *ddp_dl, *aarp_dl;
 static const struct proto_ops atalk_dgram_ops;
diff --git a/net/appletalk/dev.c b/drivers/staging/appletalk/dev.c
similarity index 100%
rename from net/appletalk/dev.c
rename to drivers/staging/appletalk/dev.c
diff --git a/drivers/net/appletalk/ipddp.c b/drivers/staging/appletalk/ipddp.c
similarity index 99%
rename from drivers/net/appletalk/ipddp.c
rename to drivers/staging/appletalk/ipddp.c
index 10d0dba..58b4e60 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/staging/appletalk/ipddp.c
@@ -29,12 +29,12 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ip.h>
-#include <linux/atalk.h>
 #include <linux/if_arp.h>
 #include <linux/slab.h>
 #include <net/route.h>
 #include <asm/uaccess.h>
 
+#include "atalk.h"
 #include "ipddp.h"		/* Our stuff */
 
 static const char version[] = KERN_INFO "ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>\n";
diff --git a/drivers/net/appletalk/ipddp.h b/drivers/staging/appletalk/ipddp.h
similarity index 100%
rename from drivers/net/appletalk/ipddp.h
rename to drivers/staging/appletalk/ipddp.h
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/staging/appletalk/ltpc.c
similarity index 99%
rename from drivers/net/appletalk/ltpc.c
rename to drivers/staging/appletalk/ltpc.c
index e69eead..60caf89 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/staging/appletalk/ltpc.c
@@ -225,7 +225,6 @@ static int dma;
 #include <linux/if_ltalk.h>
 #include <linux/delay.h>
 #include <linux/timer.h>
-#include <linux/atalk.h>
 #include <linux/bitops.h>
 #include <linux/gfp.h>
 
@@ -234,6 +233,7 @@ static int dma;
 #include <asm/io.h>
 
 /* our stuff */
+#include "atalk.h"
 #include "ltpc.h"
 
 static DEFINE_SPINLOCK(txqueue_lock);
diff --git a/drivers/net/appletalk/ltpc.h b/drivers/staging/appletalk/ltpc.h
similarity index 100%
rename from drivers/net/appletalk/ltpc.h
rename to drivers/staging/appletalk/ltpc.h
diff --git a/net/appletalk/sysctl_net_atalk.c b/drivers/staging/appletalk/sysctl_net_atalk.c
similarity index 98%
rename from net/appletalk/sysctl_net_atalk.c
rename to drivers/staging/appletalk/sysctl_net_atalk.c
index 04e9c0d..4c896b6 100644
--- a/net/appletalk/sysctl_net_atalk.c
+++ b/drivers/staging/appletalk/sysctl_net_atalk.c
@@ -8,7 +8,7 @@
 
 #include <linux/sysctl.h>
 #include <net/sock.h>
-#include <linux/atalk.h>
+#include "atalk.h"
 
 static struct ctl_table atalk_table[] = {
 	{
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 61abb63..86a2d7d 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -56,7 +56,6 @@
 #include <linux/syscalls.h>
 #include <linux/i2c.h>
 #include <linux/i2c-dev.h>
-#include <linux/atalk.h>
 #include <linux/gfp.h>
 
 #include <net/bluetooth/bluetooth.h>
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 2296d8b..362041b 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -43,7 +43,6 @@ header-y += agpgart.h
 header-y += aio_abi.h
 header-y += apm_bios.h
 header-y += arcfb.h
-header-y += atalk.h
 header-y += atm.h
 header-y += atm_eni.h
 header-y += atm_he.h
diff --git a/net/Kconfig b/net/Kconfig
index 7284062..082c8bc 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -204,7 +204,6 @@ source "net/8021q/Kconfig"
 source "net/decnet/Kconfig"
 source "net/llc/Kconfig"
 source "net/ipx/Kconfig"
-source "drivers/net/appletalk/Kconfig"
 source "net/x25/Kconfig"
 source "net/lapb/Kconfig"
 source "net/econet/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index a3330eb..16d9947 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -27,7 +27,6 @@ obj-$(CONFIG_NET_KEY)		+= key/
 obj-$(CONFIG_BRIDGE)		+= bridge/
 obj-$(CONFIG_NET_DSA)		+= dsa/
 obj-$(CONFIG_IPX)		+= ipx/
-obj-$(CONFIG_ATALK)		+= appletalk/
 obj-$(CONFIG_WAN_ROUTER)	+= wanrouter/
 obj-$(CONFIG_X25)		+= x25/
 obj-$(CONFIG_LAPB)		+= lapb/
diff --git a/net/socket.c b/net/socket.c
index ac2219f..26f7bcf 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -103,7 +103,6 @@
 #include <linux/ipv6_route.h>
 #include <linux/route.h>
 #include <linux/sockios.h>
-#include <linux/atalk.h>
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
-- 
1.7.1
