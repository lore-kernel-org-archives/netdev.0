From: Joe Perches <joe@perches.com>
Subject: [PATCH] wanrouter: Remove it and the drivers that depend on it
Date: Sat, 10 Nov 2012 06:20:55 -0800
Message-ID: <67fe0c5701a8c7cfe06b178cf04b1c5c06592714.1352548454.git.joe@perches.com>
Cc: Russell King <linux@arm.linux.org.uk>,
	Ralf Baechle <ralf@linux-mips.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Chris Zankel <chris@zankel.net>,
	Max Filippov <jcmvbkbc@gmail.com>,
	Karsten Keil <isdn@linux-pingi.de>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	xiyoulinuxkernelgroup@googlegroups.com, linux-kernel@zh-kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org
To: Rob Landley <rob@landley.net>, Harry Wei <harryxiyou@gmail.com>,
	Jeff Dike <jdike@addtoit.com>,
	Richard Weinberger <richard@nod.at>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove wanrouter as it's obsolete and has not been updated
by sangoma since 2.4.3 or so and it's not used anymore.

Remove obsolete cyclomx drivers.
Update defconfig files that enable wanrouter.
Update files that include now deleted wanrouter bits.

Signed-off-by: Joe Perches <joe@perches.com>
---
 Documentation/ioctl/ioctl-number.txt           |    1 -
 Documentation/magic-number.txt                 |    1 -
 Documentation/zh_CN/magic-number.txt           |    1 -
 arch/arm/configs/ixp4xx_defconfig              |    2 -
 arch/mips/configs/gpr_defconfig                |    3 -
 arch/mips/configs/mtx1_defconfig               |    3 -
 arch/mips/configs/nlm_xlp_defconfig            |    1 -
 arch/mips/configs/nlm_xlr_defconfig            |    1 -
 arch/powerpc/configs/86xx/gef_sbc610_defconfig |    1 -
 arch/powerpc/configs/86xx/sbc8641d_defconfig   |    1 -
 arch/powerpc/configs/ppc6xx_defconfig          |    1 -
 arch/um/defconfig                              |    1 -
 arch/xtensa/configs/common_defconfig           |    1 -
 arch/xtensa/configs/iss_defconfig              |    1 -
 arch/xtensa/configs/s6105_defconfig            |    1 -
 drivers/isdn/i4l/isdn_x25iface.c               |    1 -
 drivers/isdn/i4l/isdn_x25iface.h               |    1 -
 drivers/net/wan/Kconfig                        |   54 -
 drivers/net/wan/Makefile                       |    5 -
 drivers/net/wan/cycx_drv.c                     |  569 ---------
 drivers/net/wan/cycx_main.c                    |  346 -----
 drivers/net/wan/cycx_x25.c                     | 1602 ------------------------
 include/linux/cyclomx.h                        |   77 --
 include/linux/cycx_drv.h                       |   64 -
 include/linux/wanrouter.h                      |  129 --
 include/uapi/linux/Kbuild                      |    1 -
 include/uapi/linux/wanrouter.h                 |  452 -------
 net/Kconfig                                    |    1 -
 net/Makefile                                   |    1 -
 net/socket.c                                   |    1 -
 net/wanrouter/Kconfig                          |   27 -
 net/wanrouter/Makefile                         |    7 -
 net/wanrouter/patchlevel                       |    1 -
 net/wanrouter/wanmain.c                        |  782 ------------
 net/wanrouter/wanproc.c                        |  380 ------
 35 files changed, 0 insertions(+), 4521 deletions(-)
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
diff --git a/arch/arm/configs/ixp4xx_defconfig b/arch/arm/configs/ixp4xx_defconfig
index 063e2ab..572f712 100644
--- a/arch/arm/configs/ixp4xx_defconfig
+++ b/arch/arm/configs/ixp4xx_defconfig
@@ -91,7 +91,6 @@ CONFIG_LAPB=m
 CONFIG_ECONET=m
 CONFIG_ECONET_AUNUDP=y
 CONFIG_ECONET_NATIVE=y
-CONFIG_WAN_ROUTER=m
 CONFIG_NET_SCHED=y
 CONFIG_NET_SCH_CBQ=m
 CONFIG_NET_SCH_HTB=m
@@ -152,7 +151,6 @@ CONFIG_HDLC_FR=m
 CONFIG_HDLC_PPP=m
 CONFIG_HDLC_X25=m
 CONFIG_DLCI=m
-CONFIG_WAN_ROUTER_DRIVERS=m
 CONFIG_ATM_TCP=m
 # CONFIG_INPUT_KEYBOARD is not set
 # CONFIG_INPUT_MOUSE is not set
diff --git a/arch/mips/configs/gpr_defconfig b/arch/mips/configs/gpr_defconfig
index 48a40ae..0e7ccf2 100644
--- a/arch/mips/configs/gpr_defconfig
+++ b/arch/mips/configs/gpr_defconfig
@@ -119,7 +119,6 @@ CONFIG_LAPB=m
 CONFIG_ECONET=m
 CONFIG_ECONET_AUNUDP=y
 CONFIG_ECONET_NATIVE=y
-CONFIG_WAN_ROUTER=m
 CONFIG_NET_SCHED=y
 CONFIG_NET_SCH_CBQ=m
 CONFIG_NET_SCH_HTB=m
@@ -222,8 +221,6 @@ CONFIG_DSCC4=m
 CONFIG_DSCC4_PCISYNC=y
 CONFIG_DSCC4_PCI_RST=y
 CONFIG_DLCI=m
-CONFIG_WAN_ROUTER_DRIVERS=m
-CONFIG_CYCLADES_SYNC=m
 CONFIG_CYCLOMX_X25=y
 CONFIG_LAPBETHER=m
 CONFIG_X25_ASY=m
diff --git a/arch/mips/configs/mtx1_defconfig b/arch/mips/configs/mtx1_defconfig
index 46c61edc..d0b1195 100644
--- a/arch/mips/configs/mtx1_defconfig
+++ b/arch/mips/configs/mtx1_defconfig
@@ -157,7 +157,6 @@ CONFIG_LAPB=m
 CONFIG_ECONET=m
 CONFIG_ECONET_AUNUDP=y
 CONFIG_ECONET_NATIVE=y
-CONFIG_WAN_ROUTER=m
 CONFIG_NET_SCHED=y
 CONFIG_NET_SCH_CBQ=m
 CONFIG_NET_SCH_HTB=m
@@ -389,8 +388,6 @@ CONFIG_DSCC4=m
 CONFIG_DSCC4_PCISYNC=y
 CONFIG_DSCC4_PCI_RST=y
 CONFIG_DLCI=m
-CONFIG_WAN_ROUTER_DRIVERS=m
-CONFIG_CYCLADES_SYNC=m
 CONFIG_CYCLOMX_X25=y
 CONFIG_LAPBETHER=m
 CONFIG_X25_ASY=m
diff --git a/arch/mips/configs/nlm_xlp_defconfig b/arch/mips/configs/nlm_xlp_defconfig
index 5468b1c..9c458e1 100644
--- a/arch/mips/configs/nlm_xlp_defconfig
+++ b/arch/mips/configs/nlm_xlp_defconfig
@@ -265,7 +265,6 @@ CONFIG_IPDDP_ENCAP=y
 CONFIG_IPDDP_DECAP=y
 CONFIG_X25=m
 CONFIG_LAPB=m
-CONFIG_WAN_ROUTER=m
 CONFIG_PHONET=m
 CONFIG_IEEE802154=m
 CONFIG_NET_SCHED=y
diff --git a/arch/mips/configs/nlm_xlr_defconfig b/arch/mips/configs/nlm_xlr_defconfig
index 44b4734..abf006e 100644
--- a/arch/mips/configs/nlm_xlr_defconfig
+++ b/arch/mips/configs/nlm_xlr_defconfig
@@ -251,7 +251,6 @@ CONFIG_LAPB=m
 CONFIG_ECONET=m
 CONFIG_ECONET_AUNUDP=y
 CONFIG_ECONET_NATIVE=y
-CONFIG_WAN_ROUTER=m
 CONFIG_PHONET=m
 CONFIG_IEEE802154=m
 CONFIG_NET_SCHED=y
diff --git a/arch/powerpc/configs/86xx/gef_sbc610_defconfig b/arch/powerpc/configs/86xx/gef_sbc610_defconfig
index af2e8e1..6c21c8c 100644
--- a/arch/powerpc/configs/86xx/gef_sbc610_defconfig
+++ b/arch/powerpc/configs/86xx/gef_sbc610_defconfig
@@ -99,7 +99,6 @@ CONFIG_ATM_MPOA=m
 CONFIG_ATM_BR2684=m
 CONFIG_BRIDGE=m
 CONFIG_VLAN_8021Q=m
-CONFIG_WAN_ROUTER=m
 CONFIG_NET_SCHED=y
 CONFIG_NET_SCH_CBQ=m
 CONFIG_NET_SCH_HTB=m
diff --git a/arch/powerpc/configs/86xx/sbc8641d_defconfig b/arch/powerpc/configs/86xx/sbc8641d_defconfig
index 0a92ca0..d1082fb 100644
--- a/arch/powerpc/configs/86xx/sbc8641d_defconfig
+++ b/arch/powerpc/configs/86xx/sbc8641d_defconfig
@@ -96,7 +96,6 @@ CONFIG_ATM_MPOA=m
 CONFIG_ATM_BR2684=m
 CONFIG_BRIDGE=m
 CONFIG_VLAN_8021Q=m
-CONFIG_WAN_ROUTER=m
 CONFIG_NET_SCHED=y
 CONFIG_NET_SCH_CBQ=m
 CONFIG_NET_SCH_HTB=m
diff --git a/arch/powerpc/configs/ppc6xx_defconfig b/arch/powerpc/configs/ppc6xx_defconfig
index be1cb6e..dc27658 100644
--- a/arch/powerpc/configs/ppc6xx_defconfig
+++ b/arch/powerpc/configs/ppc6xx_defconfig
@@ -285,7 +285,6 @@ CONFIG_DEV_APPLETALK=m
 CONFIG_IPDDP=m
 CONFIG_IPDDP_ENCAP=y
 CONFIG_IPDDP_DECAP=y
-CONFIG_WAN_ROUTER=m
 CONFIG_NET_SCHED=y
 CONFIG_NET_SCH_CBQ=m
 CONFIG_NET_SCH_HTB=m
diff --git a/arch/um/defconfig b/arch/um/defconfig
index 08107a7..cd7aacd 100644
--- a/arch/um/defconfig
+++ b/arch/um/defconfig
@@ -526,7 +526,6 @@ CONFIG_DEFAULT_TCP_CONG="cubic"
 # CONFIG_X25 is not set
 # CONFIG_LAPB is not set
 # CONFIG_ECONET is not set
-# CONFIG_WAN_ROUTER is not set
 # CONFIG_PHONET is not set
 # CONFIG_IEEE802154 is not set
 # CONFIG_NET_SCHED is not set
diff --git a/arch/xtensa/configs/common_defconfig b/arch/xtensa/configs/common_defconfig
index a182a4e..47c6df7 100644
--- a/arch/xtensa/configs/common_defconfig
+++ b/arch/xtensa/configs/common_defconfig
@@ -240,7 +240,6 @@ CONFIG_IP_PNP_RARP=y
 # CONFIG_LAPB is not set
 # CONFIG_NET_DIVERT is not set
 # CONFIG_ECONET is not set
-# CONFIG_WAN_ROUTER is not set
 
 #
 # QoS and/or fair queueing
diff --git a/arch/xtensa/configs/iss_defconfig b/arch/xtensa/configs/iss_defconfig
index ddab37b..89003ab 100644
--- a/arch/xtensa/configs/iss_defconfig
+++ b/arch/xtensa/configs/iss_defconfig
@@ -249,7 +249,6 @@ CONFIG_DEFAULT_TCP_CONG="cubic"
 # CONFIG_X25 is not set
 # CONFIG_LAPB is not set
 # CONFIG_ECONET is not set
-# CONFIG_WAN_ROUTER is not set
 # CONFIG_PHONET is not set
 # CONFIG_IEEE802154 is not set
 # CONFIG_NET_SCHED is not set
diff --git a/arch/xtensa/configs/s6105_defconfig b/arch/xtensa/configs/s6105_defconfig
index eaf1b8f..456254b 100644
--- a/arch/xtensa/configs/s6105_defconfig
+++ b/arch/xtensa/configs/s6105_defconfig
@@ -203,7 +203,6 @@ CONFIG_DEFAULT_TCP_CONG="cubic"
 # CONFIG_X25 is not set
 # CONFIG_LAPB is not set
 # CONFIG_ECONET is not set
-# CONFIG_WAN_ROUTER is not set
 # CONFIG_NET_SCHED is not set
 # CONFIG_DCB is not set
 
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
index eac709b..9055dd9 100644
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

