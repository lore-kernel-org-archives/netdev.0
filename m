From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] econet: Move to staging; remove from defconfig
Date: Sat, 27 Nov 2010 22:44:28 +0000
Message-ID: <1290897868.3292.59.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-arm-kernel@lists.infradead.org,
	Debian kernel maintainers <debian-kernel@lists.debian.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55352 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753587Ab0K0Wog convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 17:44:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent review has revealed several bugs in econet and other obscure
protocol implementations that can be exploited by local users for
denial of service or privilege escalation.

The econet protocol (PF_ECONET) is unmaintained.  There appear to be
no published applications for it, and it has never progressed beyond
'experimental' status.

This protocol generally should not be enabled by distributions, since
the cost of a security flaw affecting all installed systems presumably
outweighs the benefit to the few (if any) legitimate users.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
As requested, I'm actually renaming the directory this time.  I also
noticed that ECONET was enabled in a couple of ARM defconfigs and
explicitly disabled in various other defconfigs, so I've removed those
lines as well.

This is based on linux-next; I hope it applies to staging.

Ben.

 arch/arm/configs/ixp4xx_defconfig           |    3 ---
 arch/arm/configs/pnx4008_defconfig          |    3 ---
 arch/mips/configs/gpr_defconfig             |    3 ---
 arch/mips/configs/mtx1_defconfig            |    3 ---
 arch/um/defconfig                           |    1 -
 arch/xtensa/configs/common_defconfig        |    1 -
 arch/xtensa/configs/iss_defconfig           |    1 -
 arch/xtensa/configs/s6105_defconfig         |    1 -
 drivers/staging/Kconfig                     |    2 ++
 drivers/staging/Makefile                    |    1 +
 {net => drivers/staging}/econet/Kconfig     |    0
 {net => drivers/staging}/econet/Makefile    |    0
 {net => drivers/staging}/econet/af_econet.c |    0
 net/Kconfig                                 |    1 -
 net/Makefile                                |    1 -
 15 files changed, 3 insertions(+), 18 deletions(-)
 rename {net => drivers/staging}/econet/Kconfig (100%)
 rename {net => drivers/staging}/econet/Makefile (100%)
 rename {net => drivers/staging}/econet/af_econet.c (100%)

diff --git a/arch/arm/configs/ixp4xx_defconfig b/arch/arm/configs/ixp4xx_defconfig
index 5c50239..bd85c32 100644
--- a/arch/arm/configs/ixp4xx_defconfig
+++ b/arch/arm/configs/ixp4xx_defconfig
@@ -88,9 +88,6 @@ CONFIG_IPDDP_ENCAP=y
 CONFIG_IPDDP_DECAP=y
 CONFIG_X25=m
 CONFIG_LAPB=m
-CONFIG_ECONET=m
-CONFIG_ECONET_AUNUDP=y
-CONFIG_ECONET_NATIVE=y
 CONFIG_WAN_ROUTER=m
 CONFIG_NET_SCHED=y
 CONFIG_NET_SCH_CBQ=m
diff --git a/arch/arm/configs/pnx4008_defconfig b/arch/arm/configs/pnx4008_defconfig
index bd481f0..8301e4a 100644
--- a/arch/arm/configs/pnx4008_defconfig
+++ b/arch/arm/configs/pnx4008_defconfig
@@ -101,9 +101,6 @@ CONFIG_IPDDP_ENCAP=y
 CONFIG_IPDDP_DECAP=y
 CONFIG_X25=m
 CONFIG_LAPB=m
-CONFIG_ECONET=m
-CONFIG_ECONET_AUNUDP=y
-CONFIG_ECONET_NATIVE=y
 CONFIG_WAN_ROUTER=m
 CONFIG_NET_SCHED=y
 CONFIG_NET_SCH_CBQ=m
diff --git a/arch/mips/configs/gpr_defconfig b/arch/mips/configs/gpr_defconfig
index 53edc13..9f9aa97 100644
--- a/arch/mips/configs/gpr_defconfig
+++ b/arch/mips/configs/gpr_defconfig
@@ -116,9 +116,6 @@ CONFIG_IPDDP_ENCAP=y
 CONFIG_IPDDP_DECAP=y
 CONFIG_X25=m
 CONFIG_LAPB=m
-CONFIG_ECONET=m
-CONFIG_ECONET_AUNUDP=y
-CONFIG_ECONET_NATIVE=y
 CONFIG_WAN_ROUTER=m
 CONFIG_NET_SCHED=y
 CONFIG_NET_SCH_CBQ=m
diff --git a/arch/mips/configs/mtx1_defconfig b/arch/mips/configs/mtx1_defconfig
index 8146997..79cfb0b 100644
--- a/arch/mips/configs/mtx1_defconfig
+++ b/arch/mips/configs/mtx1_defconfig
@@ -154,9 +154,6 @@ CONFIG_IPDDP_ENCAP=y
 CONFIG_IPDDP_DECAP=y
 CONFIG_X25=m
 CONFIG_LAPB=m
-CONFIG_ECONET=m
-CONFIG_ECONET_AUNUDP=y
-CONFIG_ECONET_NATIVE=y
 CONFIG_WAN_ROUTER=m
 CONFIG_NET_SCHED=y
 CONFIG_NET_SCH_CBQ=m
diff --git a/arch/um/defconfig b/arch/um/defconfig
index 564f3de..1fd4718 100644
--- a/arch/um/defconfig
+++ b/arch/um/defconfig
@@ -296,7 +296,6 @@ CONFIG_DEFAULT_TCP_CONG="cubic"
 # CONFIG_ATALK is not set
 # CONFIG_X25 is not set
 # CONFIG_LAPB is not set
-# CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
 # CONFIG_NET_SCHED is not set
 
diff --git a/arch/xtensa/configs/common_defconfig b/arch/xtensa/configs/common_defconfig
index 1d230ee..8c8916c 100644
--- a/arch/xtensa/configs/common_defconfig
+++ b/arch/xtensa/configs/common_defconfig
@@ -239,7 +239,6 @@ CONFIG_IP_PNP_RARP=y
 # CONFIG_X25 is not set
 # CONFIG_LAPB is not set
 # CONFIG_NET_DIVERT is not set
-# CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
 
 #
diff --git a/arch/xtensa/configs/iss_defconfig b/arch/xtensa/configs/iss_defconfig
index 7368164..de0c75f 100644
--- a/arch/xtensa/configs/iss_defconfig
+++ b/arch/xtensa/configs/iss_defconfig
@@ -249,7 +249,6 @@ CONFIG_DEFAULT_TCP_CONG="cubic"
 # CONFIG_ATALK is not set
 # CONFIG_X25 is not set
 # CONFIG_LAPB is not set
-# CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
 # CONFIG_PHONET is not set
 # CONFIG_IEEE802154 is not set
diff --git a/arch/xtensa/configs/s6105_defconfig b/arch/xtensa/configs/s6105_defconfig
index bb84fbc..c273505 100644
--- a/arch/xtensa/configs/s6105_defconfig
+++ b/arch/xtensa/configs/s6105_defconfig
@@ -204,7 +204,6 @@ CONFIG_DEFAULT_TCP_CONG="cubic"
 # CONFIG_ATALK is not set
 # CONFIG_X25 is not set
 # CONFIG_LAPB is not set
-# CONFIG_ECONET is not set
 # CONFIG_WAN_ROUTER is not set
 # CONFIG_NET_SCHED is not set
 # CONFIG_DCB is not set
diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 9f83e21..695110d 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -192,5 +192,7 @@ source "drivers/staging/cptm1217/Kconfig"
 
 source "drivers/staging/ste_rmi4/Kconfig"
 
+source "drivers/staging/econet/Kconfig"
+
 endif # !STAGING_EXCLUDE_BUILD
 endif # STAGING
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index 75c0c1f..03f08ed 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -71,3 +71,4 @@ obj-$(CONFIG_SND_INTEL_SST)		+= intel_sst/
 obj-$(CONFIG_SPEAKUP)	+= speakup/
 obj-$(CONFIG_TOUCHSCREEN_CLEARPAD_TM1217)	+= cptm1217/
 obj-$(CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4)	+= ste_rmi4/
+obj-$(CONFIG_ECONET)		+= econet/
diff --git a/net/econet/Kconfig b/drivers/staging/econet/Kconfig
similarity index 100%
rename from net/econet/Kconfig
rename to drivers/staging/econet/Kconfig
diff --git a/net/econet/Makefile b/drivers/staging/econet/Makefile
similarity index 100%
rename from net/econet/Makefile
rename to drivers/staging/econet/Makefile
diff --git a/net/econet/af_econet.c b/drivers/staging/econet/af_econet.c
similarity index 100%
rename from net/econet/af_econet.c
rename to drivers/staging/econet/af_econet.c
diff --git a/net/Kconfig b/net/Kconfig
index 5e203b5..4d5b5ed 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -207,7 +207,6 @@ source "net/ipx/Kconfig"
 source "drivers/net/appletalk/Kconfig"
 source "net/x25/Kconfig"
 source "net/lapb/Kconfig"
-source "net/econet/Kconfig"
 source "net/wanrouter/Kconfig"
 source "net/phonet/Kconfig"
 source "net/ieee802154/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index 6b7bfd7..0f4ed79 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -42,7 +42,6 @@ obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
 obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_L2TP)		+= l2tp/
 obj-$(CONFIG_DECNET)		+= decnet/
-obj-$(CONFIG_ECONET)		+= econet/
 obj-$(CONFIG_PHONET)		+= phonet/
 ifneq ($(CONFIG_VLAN_8021Q),)
 obj-y				+= 8021q/
-- 
1.7.2.3


