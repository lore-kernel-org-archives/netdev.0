From: Greg Kroah-Hartman <gregkh@suse.de>
Subject: [PATCH 183/961] Revert "appletalk: move to staging"
Date: Wed, 16 Mar 2011 13:57:06 -0700
Message-ID: <1300309804-3756-183-git-send-email-gregkh@suse.de>
References: <20110316210300.GA3311@kroah.com>
 <1300309804-3756-1-git-send-email-gregkh@suse.de>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Arnd Bergmann <arnd@arndb.de>,
	<acme@ghostprotocols.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: devel@linuxdriverproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:32804 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754855Ab1CPVOn (ORCPT <rfc822;netdev@vger.kernel.org,>);
	Wed, 16 Mar 2011 17:14:43 -0400
In-Reply-To: <1300309804-3756-1-git-send-email-gregkh@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit a6238f21736af3f47bdebf3895f477f5f23f1af9

Appletalk got some patches to fix up the BLK usage in it in the
network tree, so this removal isn't needed.

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: <acme@ghostprotocols.net>
Cc: netdev@vger.kernel.org,
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
---
 MAINTAINERS                                        |    3 ++-
 drivers/net/Makefile                               |    1 +
 drivers/{staging => net}/appletalk/Kconfig         |    0
 drivers/net/appletalk/Makefile                     |    7 +++++++
 drivers/{staging => net}/appletalk/cops.c          |    2 +-
 drivers/{staging => net}/appletalk/cops.h          |    0
 drivers/{staging => net}/appletalk/cops_ffdrv.h    |    0
 drivers/{staging => net}/appletalk/cops_ltdrv.h    |    0
 drivers/{staging => net}/appletalk/ipddp.c         |    2 +-
 drivers/{staging => net}/appletalk/ipddp.h         |    0
 drivers/{staging => net}/appletalk/ltpc.c          |    2 +-
 drivers/{staging => net}/appletalk/ltpc.h          |    0
 drivers/staging/Kconfig                            |    2 --
 drivers/staging/Makefile                           |    1 -
 fs/compat_ioctl.c                                  |    1 +
 include/linux/Kbuild                               |    1 +
 .../staging/appletalk => include/linux}/atalk.h    |    0
 net/Kconfig                                        |    1 +
 net/Makefile                                       |    1 +
 {drivers/staging => net}/appletalk/Makefile        |    7 ++-----
 {drivers/staging => net}/appletalk/aarp.c          |    2 +-
 {drivers/staging => net}/appletalk/atalk_proc.c    |    2 +-
 {drivers/staging => net}/appletalk/ddp.c           |    4 ++--
 {drivers/staging => net}/appletalk/dev.c           |    0
 .../staging => net}/appletalk/sysctl_net_atalk.c   |    2 +-
 net/socket.c                                       |    1 +
 26 files changed, 25 insertions(+), 17 deletions(-)
 rename drivers/{staging => net}/appletalk/Kconfig (100%)
 create mode 100644 drivers/net/appletalk/Makefile
 rename drivers/{staging => net}/appletalk/cops.c (99%)
 rename drivers/{staging => net}/appletalk/cops.h (100%)
 rename drivers/{staging => net}/appletalk/cops_ffdrv.h (100%)
 rename drivers/{staging => net}/appletalk/cops_ltdrv.h (100%)
 rename drivers/{staging => net}/appletalk/ipddp.c (99%)
 rename drivers/{staging => net}/appletalk/ipddp.h (100%)
 rename drivers/{staging => net}/appletalk/ltpc.c (99%)
 rename drivers/{staging => net}/appletalk/ltpc.h (100%)
 rename {drivers/staging/appletalk => include/linux}/atalk.h (100%)
 rename {drivers/staging => net}/appletalk/Makefile (56%)
 rename {drivers/staging => net}/appletalk/aarp.c (99%)
 rename {drivers/staging => net}/appletalk/atalk_proc.c (99%)
 rename {drivers/staging => net}/appletalk/ddp.c (99%)
 rename {drivers/staging => net}/appletalk/dev.c (100%)
 rename {drivers/staging => net}/appletalk/sysctl_net_atalk.c (98%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 3118d67..dd6ca45 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -554,7 +554,8 @@ F:	drivers/hwmon/applesmc.c
 APPLETALK NETWORK LAYER
 M:	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
 S:	Maintained
-F:	drivers/staging/appletalk/
+F:	drivers/net/appletalk/
+F:	net/appletalk/
 
 ARC FRAMEBUFFER DRIVER
 M:	Jaya Kumar <jayalk@intworks.biz>
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 11a9c05..b90738d 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -265,6 +265,7 @@ obj-$(CONFIG_MACB) += macb.o
 obj-$(CONFIG_S6GMAC) += s6gmac.o
 
 obj-$(CONFIG_ARM) += arm/
+obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
 obj-$(CONFIG_ARCNET) += arcnet/
diff --git a/drivers/staging/appletalk/Kconfig b/drivers/net/appletalk/Kconfig
similarity index 100%
rename from drivers/staging/appletalk/Kconfig
rename to drivers/net/appletalk/Kconfig
diff --git a/drivers/net/appletalk/Makefile b/drivers/net/appletalk/Makefile
new file mode 100644
index 0000000..6cfc705
--- /dev/null
+++ b/drivers/net/appletalk/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for drivers/net/appletalk
+#
+
+obj-$(CONFIG_IPDDP) += ipddp.o
+obj-$(CONFIG_COPS) += cops.o
+obj-$(CONFIG_LTPC) += ltpc.o
diff --git a/drivers/staging/appletalk/cops.c b/drivers/net/appletalk/cops.c
similarity index 99%
rename from drivers/staging/appletalk/cops.c
rename to drivers/net/appletalk/cops.c
index 661d42e..748c9f5 100644
--- a/drivers/staging/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -65,6 +65,7 @@ static const char *version =
 #include <linux/if_arp.h>
 #include <linux/if_ltalk.h>
 #include <linux/delay.h>	/* For udelay() */
+#include <linux/atalk.h>
 #include <linux/spinlock.h>
 #include <linux/bitops.h>
 #include <linux/jiffies.h>
@@ -73,7 +74,6 @@ static const char *version =
 #include <asm/io.h>
 #include <asm/dma.h>
 
-#include "atalk.h"
 #include "cops.h"		/* Our Stuff */
 #include "cops_ltdrv.h"		/* Firmware code for Tangent type cards. */
 #include "cops_ffdrv.h"		/* Firmware code for Dayna type cards. */
diff --git a/drivers/staging/appletalk/cops.h b/drivers/net/appletalk/cops.h
similarity index 100%
rename from drivers/staging/appletalk/cops.h
rename to drivers/net/appletalk/cops.h
diff --git a/drivers/staging/appletalk/cops_ffdrv.h b/drivers/net/appletalk/cops_ffdrv.h
similarity index 100%
rename from drivers/staging/appletalk/cops_ffdrv.h
rename to drivers/net/appletalk/cops_ffdrv.h
diff --git a/drivers/staging/appletalk/cops_ltdrv.h b/drivers/net/appletalk/cops_ltdrv.h
similarity index 100%
rename from drivers/staging/appletalk/cops_ltdrv.h
rename to drivers/net/appletalk/cops_ltdrv.h
diff --git a/drivers/staging/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
similarity index 99%
rename from drivers/staging/appletalk/ipddp.c
rename to drivers/net/appletalk/ipddp.c
index 58b4e60..10d0dba 100644
--- a/drivers/staging/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -29,12 +29,12 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ip.h>
+#include <linux/atalk.h>
 #include <linux/if_arp.h>
 #include <linux/slab.h>
 #include <net/route.h>
 #include <asm/uaccess.h>
 
-#include "atalk.h"
 #include "ipddp.h"		/* Our stuff */
 
 static const char version[] = KERN_INFO "ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.tc.umn.edu>\n";
diff --git a/drivers/staging/appletalk/ipddp.h b/drivers/net/appletalk/ipddp.h
similarity index 100%
rename from drivers/staging/appletalk/ipddp.h
rename to drivers/net/appletalk/ipddp.h
diff --git a/drivers/staging/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
similarity index 99%
rename from drivers/staging/appletalk/ltpc.c
rename to drivers/net/appletalk/ltpc.c
index 60caf89..e69eead 100644
--- a/drivers/staging/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -225,6 +225,7 @@ static int dma;
 #include <linux/if_ltalk.h>
 #include <linux/delay.h>
 #include <linux/timer.h>
+#include <linux/atalk.h>
 #include <linux/bitops.h>
 #include <linux/gfp.h>
 
@@ -233,7 +234,6 @@ static int dma;
 #include <asm/io.h>
 
 /* our stuff */
-#include "atalk.h"
 #include "ltpc.h"
 
 static DEFINE_SPINLOCK(txqueue_lock);
diff --git a/drivers/staging/appletalk/ltpc.h b/drivers/net/appletalk/ltpc.h
similarity index 100%
rename from drivers/staging/appletalk/ltpc.h
rename to drivers/net/appletalk/ltpc.h
diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 584d4e2..b80755d 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -169,8 +169,6 @@ source "drivers/staging/bcm/Kconfig"
 
 source "drivers/staging/ft1000/Kconfig"
 
-source "drivers/staging/appletalk/Kconfig"
-
 source "drivers/staging/intel_sst/Kconfig"
 
 source "drivers/staging/speakup/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 88f0c64..fd26509 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -65,7 +65,6 @@ obj-$(CONFIG_ATH6K_LEGACY)	+= ath6kl/
 obj-$(CONFIG_USB_ENESTORAGE)	+= keucr/
 obj-$(CONFIG_BCM_WIMAX)	+= bcm/
 obj-$(CONFIG_FT1000)		+= ft1000/
-obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_SND_INTEL_SST)		+= intel_sst/
 obj-$(CONFIG_SPEAKUP)	+= speakup/
 obj-$(CONFIG_TOUCHSCREEN_CLEARPAD_TM1217)	+= cptm1217/
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 86a2d7d..61abb63 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -56,6 +56,7 @@
 #include <linux/syscalls.h>
 #include <linux/i2c.h>
 #include <linux/i2c-dev.h>
+#include <linux/atalk.h>
 #include <linux/gfp.h>
 
 #include <net/bluetooth/bluetooth.h>
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 362041b..2296d8b 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -43,6 +43,7 @@ header-y += agpgart.h
 header-y += aio_abi.h
 header-y += apm_bios.h
 header-y += arcfb.h
+header-y += atalk.h
 header-y += atm.h
 header-y += atm_eni.h
 header-y += atm_he.h
diff --git a/drivers/staging/appletalk/atalk.h b/include/linux/atalk.h
similarity index 100%
rename from drivers/staging/appletalk/atalk.h
rename to include/linux/atalk.h
diff --git a/net/Kconfig b/net/Kconfig
index 082c8bc..7284062 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -204,6 +204,7 @@ source "net/8021q/Kconfig"
 source "net/decnet/Kconfig"
 source "net/llc/Kconfig"
 source "net/ipx/Kconfig"
+source "drivers/net/appletalk/Kconfig"
 source "net/x25/Kconfig"
 source "net/lapb/Kconfig"
 source "net/econet/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index 16d9947..a3330eb 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_NET_KEY)		+= key/
 obj-$(CONFIG_BRIDGE)		+= bridge/
 obj-$(CONFIG_NET_DSA)		+= dsa/
 obj-$(CONFIG_IPX)		+= ipx/
+obj-$(CONFIG_ATALK)		+= appletalk/
 obj-$(CONFIG_WAN_ROUTER)	+= wanrouter/
 obj-$(CONFIG_X25)		+= x25/
 obj-$(CONFIG_LAPB)		+= lapb/
diff --git a/drivers/staging/appletalk/Makefile b/net/appletalk/Makefile
similarity index 56%
rename from drivers/staging/appletalk/Makefile
rename to net/appletalk/Makefile
index 2a5129a..5cda56e 100644
--- a/drivers/staging/appletalk/Makefile
+++ b/net/appletalk/Makefile
@@ -1,12 +1,9 @@
 #
-# Makefile for drivers/staging/appletalk
+# Makefile for the Linux AppleTalk layer.
 #
+
 obj-$(CONFIG_ATALK) += appletalk.o
 
 appletalk-y			:= aarp.o ddp.o dev.o
 appletalk-$(CONFIG_PROC_FS)	+= atalk_proc.o
 appletalk-$(CONFIG_SYSCTL)	+= sysctl_net_atalk.o
-
-obj-$(CONFIG_IPDDP) += ipddp.o
-obj-$(CONFIG_COPS) += cops.o
-obj-$(CONFIG_LTPC) += ltpc.o
diff --git a/drivers/staging/appletalk/aarp.c b/net/appletalk/aarp.c
similarity index 99%
rename from drivers/staging/appletalk/aarp.c
rename to net/appletalk/aarp.c
index 7163a1d..50dce79 100644
--- a/drivers/staging/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -34,7 +34,7 @@
 #include <net/sock.h>
 #include <net/datalink.h>
 #include <net/psnap.h>
-#include "atalk.h"
+#include <linux/atalk.h>
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
diff --git a/drivers/staging/appletalk/atalk_proc.c b/net/appletalk/atalk_proc.c
similarity index 99%
rename from drivers/staging/appletalk/atalk_proc.c
rename to net/appletalk/atalk_proc.c
index d012ba2..6ef0e76 100644
--- a/drivers/staging/appletalk/atalk_proc.c
+++ b/net/appletalk/atalk_proc.c
@@ -13,7 +13,7 @@
 #include <linux/seq_file.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
-#include "atalk.h"
+#include <linux/atalk.h>
 
 
 static __inline__ struct atalk_iface *atalk_get_interface_idx(loff_t pos)
diff --git a/drivers/staging/appletalk/ddp.c b/net/appletalk/ddp.c
similarity index 99%
rename from drivers/staging/appletalk/ddp.c
rename to net/appletalk/ddp.c
index 940dd19..c410b93 100644
--- a/drivers/staging/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -63,8 +63,8 @@
 #include <net/sock.h>
 #include <net/tcp_states.h>
 #include <net/route.h>
-#include "atalk.h"
-#include "../../net/core/kmap_skb.h"
+#include <linux/atalk.h>
+#include "../core/kmap_skb.h"
 
 struct datalink_proto *ddp_dl, *aarp_dl;
 static const struct proto_ops atalk_dgram_ops;
diff --git a/drivers/staging/appletalk/dev.c b/net/appletalk/dev.c
similarity index 100%
rename from drivers/staging/appletalk/dev.c
rename to net/appletalk/dev.c
diff --git a/drivers/staging/appletalk/sysctl_net_atalk.c b/net/appletalk/sysctl_net_atalk.c
similarity index 98%
rename from drivers/staging/appletalk/sysctl_net_atalk.c
rename to net/appletalk/sysctl_net_atalk.c
index 4c896b6..04e9c0d 100644
--- a/drivers/staging/appletalk/sysctl_net_atalk.c
+++ b/net/appletalk/sysctl_net_atalk.c
@@ -8,7 +8,7 @@
 
 #include <linux/sysctl.h>
 #include <net/sock.h>
-#include "atalk.h"
+#include <linux/atalk.h>
 
 static struct ctl_table atalk_table[] = {
 	{
diff --git a/net/socket.c b/net/socket.c
index 26f7bcf..ac2219f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -103,6 +103,7 @@
 #include <linux/ipv6_route.h>
 #include <linux/route.h>
 #include <linux/sockios.h>
+#include <linux/atalk.h>
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
-- 
1.7.4.1

