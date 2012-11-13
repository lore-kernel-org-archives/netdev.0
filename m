From: Joe Perches <joe@perches.com>
Subject: [PATCH V2] wanrouter: Remove it and the drivers that depend on it
Date: Tue, 13 Nov 2012 12:17:25 -0800
Message-ID: <1352837845.12850.3.camel@joe-AO722>
References: <67fe0c5701a8c7cfe06b178cf04b1c5c06592714.1352548454.git.joe@perches.com>
	 <20121113.144406.1610017702502358739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, harryxiyou@gmail.com, jdike@addtoit.com,
	richard@nod.at, linux@arm.linux.org.uk, ralf@linux-mips.org,
	benh@kernel.crashing.org, paulus@samba.org, chris@zankel.net,
	jcmvbkbc@gmail.com, isdn@linux-pingi.de, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	xiyoulinuxkernelgroup@googlegroups.com, linux-kernel@zh-kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121113.144406.1610017702502358739.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove wanrouter as it's obsolete and has not been updated
by sangoma since 2.4.3 or so and it's not used anymore.

Remove obsolete cyclomx drivers.
Update files that include now deleted wanrouter bits.

Signed-off-by: Joe Perches <joe@perches.com>
---

On Tue, 2012-11-13 at 14:44 -0500, David Miller wrote:
> Remove wanrouter as it's obsolete and has not been updated
> > by sangoma since 2.4.3 or so and it's not used anymore.
> > 
> > Remove obsolete cyclomx drivers.
> > Update defconfig files that enable wanrouter.
> > Update files that include now deleted wanrouter bits.
> []
> I'm fine with this change, except the arch defconfig bits.
> 
> We've been leaving those alone, and letting the arch maintainers
> do the updates themselves periodically.
> 
> Please resubmit this with those parts removed.

That seems an odd workflow as it leaves dangling CONFIG_<foo>
options set, but I guess it doesn't hurt so here it is.

I just removed the modified arch/.../<foo>defconfig files.

 Documentation/ioctl/ioctl-number.txt |    1 -
 Documentation/magic-number.txt       |    1 -
 Documentation/zh_CN/magic-number.txt |    1 -
 drivers/isdn/i4l/isdn_x25iface.c     |    1 -
 drivers/isdn/i4l/isdn_x25iface.h     |    1 -
 drivers/net/wan/Kconfig              |   54 --
 drivers/net/wan/Makefile             |    5 -
 drivers/net/wan/cycx_drv.c           |  569 ------------
 drivers/net/wan/cycx_main.c          |  346 --------
 drivers/net/wan/cycx_x25.c           | 1602 ----------------------------------
 include/linux/cyclomx.h              |   77 --
 include/linux/cycx_drv.h             |   64 --
 include/linux/wanrouter.h            |  129 ---
 include/uapi/linux/Kbuild            |    1 -
 include/uapi/linux/wanrouter.h       |  452 ----------
 net/Kconfig                          |    1 -
 net/Makefile                         |    1 -
 net/socket.c                         |    1 -
 net/wanrouter/Kconfig                |   27 -
 net/wanrouter/Makefile               |    7 -
 net/wanrouter/patchlevel             |    1 -
 net/wanrouter/wanmain.c              |  782 -----------------
 net/wanrouter/wanproc.c              |  380 --------
 23 files changed, 0 insertions(+), 4504 deletions(-)
 delete mode 100644 drivers/net/wan/cycx_drv.c
 delete mode 100644 drivers/net/wan/cycx_main.c
 delete mode 100644 drivers/net/wan/cycx_x25.c
 delete mode 100644 include/linux/cyclomx.h
 delete mode 100644 include/linux/cycx_drv.h
 delete mode 100644 include/linux/wanrouter.h
 delete mode 100644 include/uapi/linux/wanrouter.h
 delete mode 100644 net/wanrouter/Kconfig
 delete mode 100644 net/wanrouter/Makefile
 delete mode 100644 net/wanrouter/patchlevel
 delete mode 100644 net/wanrouter/wanmain.c
 delete mode 100644 net/wanrouter/wanproc.c

diff --git a/Documentation/ioctl/ioctl-number.txt b/Documentation/ioctl/ioctl-number.txt
index 2152b0e..028a034 100644
--- a/Documentation/ioctl/ioctl-number.txt
+++ b/Documentation/ioctl/ioctl-number.txt
@@ -179,7 +179,6 @@ Code  Seq#(hex)	Include File		Comments
 'V'	C0	media/davinci/vpfe_capture.h	conflict!
 'V'	C0	media/si4713.h		conflict!
 'W'	00-1F	linux/watchdog.h	conflict!
-'W'	00-1F	linux/wanrouter.h	conflict!
 'W'	00-3F	sound/asound.h		conflict!
 'X'	all	fs/xfs/xfs_fs.h		conflict!
 		and fs/xfs/linux-2.6/xfs_ioctl32.h
diff --git a/Documentation/magic-number.txt b/Documentation/magic-number.txt
index 82761a3..0c39e72 100644
--- a/Documentation/magic-number.txt
+++ b/Documentation/magic-number.txt
@@ -122,7 +122,6 @@ SLAB_C_MAGIC          0x4f17a36d  kmem_cache        mm/slab.c
 COW_MAGIC             0x4f4f4f4d  cow_header_v1     arch/um/drivers/ubd_user.c
 I810_CARD_MAGIC       0x5072696E  i810_card         sound/oss/i810_audio.c
 TRIDENT_CARD_MAGIC    0x5072696E  trident_card      sound/oss/trident.c
-ROUTER_MAGIC          0x524d4157  wan_device        include/linux/wanrouter.h
 SCC_MAGIC             0x52696368  gs_port           drivers/char/scc.h
 SAVEKMSG_MAGIC1       0x53415645  savekmsg          arch/*/amiga/config.c
 GDA_MAGIC             0x58464552  gda               arch/mips/include/asm/sn/gda.h
diff --git a/Documentation/zh_CN/magic-number.txt b/Documentation/zh_CN/magic-number.txt
index 4263022..51b7e15 100644
--- a/Documentation/zh_CN/magic-number.txt
+++ b/Documentation/zh_CN/magic-number.txt
@@ -122,7 +122,6 @@ SLAB_C_MAGIC          0x4f17a36d  kmem_cache        mm/slab.c
 COW_MAGIC             0x4f4f4f4d  cow_header_v1     arch/um/drivers/ubd_user.c
 I810_CARD_MAGIC       0x5072696E  i810_card         sound/oss/i810_audio.c
 TRIDENT_CARD_MAGIC    0x5072696E  trident_card      sound/oss/trident.c
-ROUTER_MAGIC          0x524d4157  wan_device        include/linux/wanrouter.h
 SCC_MAGIC             0x52696368  gs_port           drivers/char/scc.h
 SAVEKMSG_MAGIC1       0x53415645  savekmsg          arch/*/amiga/config.c
 GDA_MAGIC             0x58464552  gda               arch/mips/include/asm/sn/gda.h
diff --git a/drivers/isdn/i4l/isdn_x25iface.c b/drivers/isdn/i4l/isdn_x25iface.c
index e2d4e58..d00c86d 100644
--- a/drivers/isdn/i4l/isdn_x25iface.c
+++ b/drivers/isdn/i4l/isdn_x25iface.c
@@ -21,7 +21,6 @@
 #include <linux/netdevice.h>
 #include <linux/concap.h>
 #include <linux/slab.h>
-#include <linux/wanrouter.h>
 #include <net/x25device.h>
 #include "isdn_x25iface.h"
 
diff --git a/drivers/isdn/i4l/isdn_x25iface.h b/drivers/isdn/i4l/isdn_x25iface.h
index 0b26e3b..ca08e08 100644
--- a/drivers/isdn/i4l/isdn_x25iface.h
+++ b/drivers/isdn/i4l/isdn_x25iface.h
@@ -19,7 +19,6 @@
 #endif
 
 #include <linux/skbuff.h>
-#include <linux/wanrouter.h>
 #include <linux/isdn.h>
 #include <linux/concap.h>
 
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index d58431e..0c077b0 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -356,60 +356,6 @@ config SDLA
 	  To compile this driver as a module, choose M here: the
 	  module will be called sdla.
 
-# Wan router core.
-config WAN_ROUTER_DRIVERS
-	tristate "WAN router drivers"
-	depends on WAN_ROUTER
-	---help---
-	  Connect LAN to WAN via Linux box.
-
-	  Select driver your card and remember to say Y to "Wan Router."
-	  You will need the wan-tools package which is available from
-	  <ftp://ftp.sangoma.com/>.
-
-	  Note that the answer to this question won't directly affect the
-	  kernel except for how subordinate drivers may be built:
-	  saying N will just cause the configurator to skip all
-	  the questions about WAN router drivers.
-
-	  If unsure, say N.
-
-config CYCLADES_SYNC
-	tristate "Cyclom 2X(tm) cards (EXPERIMENTAL)"
-	depends on WAN_ROUTER_DRIVERS && (PCI || ISA)
-	---help---
-	  Cyclom 2X from Cyclades Corporation <http://www.avocent.com/> is an
-	  intelligent multiprotocol WAN adapter with data transfer rates up to
-	  512 Kbps. These cards support the X.25 and SNA related protocols.
-
-	  While no documentation is available at this time please grab the
-	  wanconfig tarball in
-	  <http://www.conectiva.com.br/~acme/cycsyn-devel/> (with minor changes
-	  to make it compile with the current wanrouter include files; efforts
-	  are being made to use the original package available at
-	  <ftp://ftp.sangoma.com/>).
-
-	  Feel free to contact me or the cycsyn-devel mailing list at
-	  <acme@conectiva.com.br> and <cycsyn-devel@bazar.conectiva.com.br> for
-	  additional details, I hope to have documentation available as soon as
-	  possible. (Cyclades Brazil is writing the Documentation).
-
-	  The next questions will ask you about the protocols you want the
-	  driver to support (for now only X.25 is supported).
-
-	  If you have one or more of these cards, say Y to this option.
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called cyclomx.
-
-config CYCLOMX_X25
-	bool "Cyclom 2X X.25 support (EXPERIMENTAL)"
-	depends on CYCLADES_SYNC
-	help
-	  Connect a Cyclom 2X card to an X.25 network.
-
-	  Enabling X.25 support will enlarge your kernel by about 11 kB.
-
 # X.25 network drivers
 config LAPBETHER
 	tristate "LAPB over Ethernet driver (EXPERIMENTAL)"
diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index df70248..c135ef4 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -5,10 +5,6 @@
 # Rewritten to use lists instead of if-statements.
 #
 
-cyclomx-y                       := cycx_main.o
-cyclomx-$(CONFIG_CYCLOMX_X25)	+= cycx_x25.o
-cyclomx-objs			:= $(cyclomx-y)  
-
 obj-$(CONFIG_HDLC)		+= hdlc.o
 obj-$(CONFIG_HDLC_RAW)		+= hdlc_raw.o
 obj-$(CONFIG_HDLC_RAW_ETH)	+= hdlc_raw_eth.o
@@ -28,7 +24,6 @@ obj-$(CONFIG_LANMEDIA)		+= lmc/
 
 obj-$(CONFIG_DLCI)		+= dlci.o 
 obj-$(CONFIG_SDLA)		+= sdla.o
-obj-$(CONFIG_CYCLADES_SYNC)	+= cycx_drv.o cyclomx.o
 obj-$(CONFIG_LAPBETHER)		+= lapbether.o
 obj-$(CONFIG_SBNI)		+= sbni.o
 obj-$(CONFIG_N2)		+= n2.o
diff --git a/drivers/net/wan/cycx_drv.c b/drivers/net/wan/cycx_drv.c
deleted file mode 100644
index 2a3ecae..0000000
diff --git a/drivers/net/wan/cycx_main.c b/drivers/net/wan/cycx_main.c
deleted file mode 100644
index 81fbbad..0000000
diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
deleted file mode 100644
index 06f3f63..0000000
diff --git a/include/linux/cyclomx.h b/include/linux/cyclomx.h
deleted file mode 100644
index b88f7f4..0000000
diff --git a/include/linux/cycx_drv.h b/include/linux/cycx_drv.h
deleted file mode 100644
index 12fe6b0..0000000
diff --git a/include/linux/wanrouter.h b/include/linux/wanrouter.h
deleted file mode 100644
index cec4b41..0000000
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index e194387..c54b7e7 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -408,7 +408,6 @@ header-y += virtio_ring.h
 header-y += virtio_rng.h
 header-y += vt.h
 header-y += wait.h
-header-y += wanrouter.h
 header-y += watchdog.h
 header-y += wimax.h
 header-y += wireless.h
diff --git a/include/uapi/linux/wanrouter.h b/include/uapi/linux/wanrouter.h
deleted file mode 100644
index 7617df2..0000000
diff --git a/net/Kconfig b/net/Kconfig
index 30b48f5..4cf4bb5 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -209,7 +209,6 @@ source "net/ipx/Kconfig"
 source "drivers/net/appletalk/Kconfig"
 source "net/x25/Kconfig"
 source "net/lapb/Kconfig"
-source "net/wanrouter/Kconfig"
 source "net/phonet/Kconfig"
 source "net/ieee802154/Kconfig"
 source "net/mac802154/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index 4f4ee08..c5aa8b3 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -26,7 +26,6 @@ obj-$(CONFIG_BRIDGE)		+= bridge/
 obj-$(CONFIG_NET_DSA)		+= dsa/
 obj-$(CONFIG_IPX)		+= ipx/
 obj-$(CONFIG_ATALK)		+= appletalk/
-obj-$(CONFIG_WAN_ROUTER)	+= wanrouter/
 obj-$(CONFIG_X25)		+= x25/
 obj-$(CONFIG_LAPB)		+= lapb/
 obj-$(CONFIG_NETROM)		+= netrom/
diff --git a/net/socket.c b/net/socket.c
index 2ca51c7..5c4d82c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -69,7 +69,6 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/mutex.h>
-#include <linux/wanrouter.h>
 #include <linux/if_bridge.h>
 #include <linux/if_frad.h>
 #include <linux/if_vlan.h>
diff --git a/net/wanrouter/Kconfig b/net/wanrouter/Kconfig
deleted file mode 100644
index a157a2e..0000000
diff --git a/net/wanrouter/Makefile b/net/wanrouter/Makefile
deleted file mode 100644
index 4da14bc..0000000
diff --git a/net/wanrouter/patchlevel b/net/wanrouter/patchlevel
deleted file mode 100644
index c043eea..0000000
diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
deleted file mode 100644
index 2ab7850..0000000
diff --git a/net/wanrouter/wanproc.c b/net/wanrouter/wanproc.c
deleted file mode 100644
index c43612e..0000000
-- 
1.7.8.112.g3fd21
