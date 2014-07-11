From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 1/2] 6lowpan: introduce new
	net/6lowpan directory
Date: Fri, 11 Jul 2014 10:24:18 +0200
Message-ID: <1405067059-18782-2-git-send-email-alex.aring@gmail.com>
References: <1405067059-18782-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1405067059-18782-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch moves generic code which is used by bluetooth and ieee802154
6lowpan to a new net/6lowpan directory. This directory contains generic
6LoWPAN code which is shared between bluetooth and ieee802154 MAC-Layer.

This is the IPHC - "IPv6 Header Compression" format at the moment. Which
is described by RFC 6282 [0]. The BLTE 6LoWPAN draft describes that the
IPHC is the same format like IEEE 802.15.4, see [1].

Futuremore we can put more code into this directory which is shared
between BLTE and IEEE 802.15.4 6LoWPAN like RFC 6775 or the routing
protocol RPL RFC 6550.

To avoid naming conflicts I renamed 6lowpan-y to ieee802154_6lowpan-y
in net/ieee802154/Makefile.

[0] http://tools.ietf.org/html/rfc6282
[1] http://tools.ietf.org/html/draft-ietf-6lowpan-btle-12#section-3.2
[2] http://tools.ietf.org/html/rfc6775
[3] http://tools.ietf.org/html/rfc6550

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/6lowpan/Kconfig                               | 6 ++++++
 net/6lowpan/Makefile                              | 3 +++
 net/{ieee802154/6lowpan_iphc.c => 6lowpan/iphc.c} | 0
 net/Kconfig                                       | 1 +
 net/Makefile                                      | 3 ++-
 net/bluetooth/Kconfig                             | 3 +--
 net/ieee802154/Kconfig                            | 9 +--------
 net/ieee802154/Makefile                           | 5 ++---
 8 files changed, 16 insertions(+), 14 deletions(-)
 create mode 100644 net/6lowpan/Kconfig
 create mode 100644 net/6lowpan/Makefile
 rename net/{ieee802154/6lowpan_iphc.c => 6lowpan/iphc.c} (100%)

diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
new file mode 100644
index 0000000..028a5c6
--- /dev/null
+++ b/net/6lowpan/Kconfig
@@ -0,0 +1,6 @@
+config 6LOWPAN
+	bool "6LoWPAN Support"
+	depends on IPV6
+	---help---
+	  This enables IPv6 over Low power Wireless Personal Area Network -
+	  "6LoWPAN" which is supported by IEEE 802.15.4 or Bluetooth stacks.
diff --git a/net/6lowpan/Makefile b/net/6lowpan/Makefile
new file mode 100644
index 0000000..415886b
--- /dev/null
+++ b/net/6lowpan/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_6LOWPAN) := 6lowpan.o
+
+6lowpan-y := iphc.o
diff --git a/net/ieee802154/6lowpan_iphc.c b/net/6lowpan/iphc.c
similarity index 100%
rename from net/ieee802154/6lowpan_iphc.c
rename to net/6lowpan/iphc.c
diff --git a/net/Kconfig b/net/Kconfig
index d92afe4..4051fdf 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -214,6 +214,7 @@ source "drivers/net/appletalk/Kconfig"
 source "net/x25/Kconfig"
 source "net/lapb/Kconfig"
 source "net/phonet/Kconfig"
+source "net/6lowpan/Kconfig"
 source "net/ieee802154/Kconfig"
 source "net/mac802154/Kconfig"
 source "net/sched/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index cbbbe6d..7ed1970 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -57,7 +57,8 @@ obj-$(CONFIG_CAIF)		+= caif/
 ifneq ($(CONFIG_DCB),)
 obj-y				+= dcb/
 endif
-obj-y				+= ieee802154/
+obj-$(CONFIG_6LOWPAN)		+= 6lowpan/
+obj-$(CONFIG_IEEE802154)	+= ieee802154/
 obj-$(CONFIG_MAC802154)		+= mac802154/
 
 ifeq ($(CONFIG_NET),y)
diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
index 06ec144..a54777d 100644
--- a/net/bluetooth/Kconfig
+++ b/net/bluetooth/Kconfig
@@ -6,7 +6,6 @@ menuconfig BT
 	tristate "Bluetooth subsystem support"
 	depends on NET && !S390
 	depends on RFKILL || !RFKILL
-	select 6LOWPAN_IPHC if BT_6LOWPAN
 	select CRC16
 	select CRYPTO
 	select CRYPTO_BLKCIPHER
@@ -42,7 +41,7 @@ menuconfig BT
 
 config BT_6LOWPAN
 	bool "Bluetooth 6LoWPAN support"
-	depends on BT && IPV6
+	depends on BT && 6LOWPAN
 	help
 	  IPv6 compression over Bluetooth.
 
diff --git a/net/ieee802154/Kconfig b/net/ieee802154/Kconfig
index 8af1330..c0d4154 100644
--- a/net/ieee802154/Kconfig
+++ b/net/ieee802154/Kconfig
@@ -12,13 +12,6 @@ config IEEE802154
 
 config IEEE802154_6LOWPAN
 	tristate "6lowpan support over IEEE 802.15.4"
-	depends on IEEE802154 && IPV6
-	select 6LOWPAN_IPHC
+	depends on IEEE802154 && 6LOWPAN
 	---help---
 	  IPv6 compression over IEEE 802.15.4.
-
-config 6LOWPAN_IPHC
-	tristate
-	---help---
-	  6lowpan compression code which is shared between IEEE 802.15.4 and Bluetooth
-	  stacks.
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
index bf1b514..3914b1e 100644
--- a/net/ieee802154/Makefile
+++ b/net/ieee802154/Makefile
@@ -1,8 +1,7 @@
 obj-$(CONFIG_IEEE802154) += ieee802154.o af_802154.o
-obj-$(CONFIG_IEEE802154_6LOWPAN) += 6lowpan.o
-obj-$(CONFIG_6LOWPAN_IPHC) += 6lowpan_iphc.o
+obj-$(CONFIG_IEEE802154_6LOWPAN) += ieee802154_6lowpan.o
 
-6lowpan-y := 6lowpan_rtnl.o reassembly.o
+ieee802154_6lowpan-y := 6lowpan_rtnl.o reassembly.o
 ieee802154-y := netlink.o nl-mac.o nl-phy.o nl_policy.o wpan-class.o \
                 header_ops.o
 af_802154-y := af_ieee802154.o raw.o dgram.o
-- 
2.0.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
