From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 3/3] dsa: Move switch drivers to new directory
 drivers/net/dsa
Date: Mon, 28 Nov 2011 03:08:33 +0000
Message-ID: <1322449713.7454.36.camel@deadeye>
References: <1322449506.7454.34.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54055 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753141Ab1K1DIm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Nov 2011 22:08:42 -0500
In-Reply-To: <1322449506.7454.34.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for specific hardware belongs under drivers/net/ not net/.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This seems to work, but again it's compile-tested only.

Ben.

 drivers/net/Kconfig                        |    2 +
 drivers/net/Makefile                       |    1 +
 drivers/net/dsa/Kconfig                    |   36 ++++++++++++++++++++++++++++
 drivers/net/dsa/Makefile                   |    9 +++++++
 {net => drivers/net}/dsa/mv88e6060.c       |    0
 {net => drivers/net}/dsa/mv88e6123_61_65.c |    0
 {net => drivers/net}/dsa/mv88e6131.c       |    0
 {net => drivers/net}/dsa/mv88e6xxx.c       |    0
 {net => drivers/net}/dsa/mv88e6xxx.h       |    0
 net/dsa/Kconfig                            |   36 +---------------------------
 net/dsa/Makefile                           |   11 --------
 11 files changed, 49 insertions(+), 46 deletions(-)
 create mode 100644 drivers/net/dsa/Kconfig
 create mode 100644 drivers/net/dsa/Makefile
 rename {net => drivers/net}/dsa/mv88e6060.c (100%)
 rename {net => drivers/net}/dsa/mv88e6123_61_65.c (100%)
 rename {net => drivers/net}/dsa/mv88e6131.c (100%)
 rename {net => drivers/net}/dsa/mv88e6xxx.c (100%)
 rename {net => drivers/net}/dsa/mv88e6xxx.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index debdf1c..9845afb 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -243,6 +243,8 @@ source "drivers/atm/Kconfig"
 
 source "drivers/net/caif/Kconfig"
 
+source "drivers/net/dsa/Kconfig"
+
 source "drivers/net/ethernet/Kconfig"
 
 source "drivers/net/fddi/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4e4ebfe..1988881 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -30,6 +30,7 @@ obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_CAIF) += caif/
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_ETRAX_ETHERNET) += cris/
+obj-$(CONFIG_NET_DSA) += dsa/
 obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_FDDI) += fddi/
 obj-$(CONFIG_HIPPI) += hippi/
diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
new file mode 100644
index 0000000..dd151d5
--- /dev/null
+++ b/drivers/net/dsa/Kconfig
@@ -0,0 +1,36 @@
+menu "Distributed Switch Architecture drivers"
+	depends on NET_DSA
+
+config NET_DSA_MV88E6XXX
+	tristate
+	default n
+
+config NET_DSA_MV88E6060
+	tristate "Marvell 88E6060 ethernet switch chip support"
+	select NET_DSA_TAG_TRAILER
+	---help---
+	  This enables support for the Marvell 88E6060 ethernet switch
+	  chip.
+
+config NET_DSA_MV88E6XXX_NEED_PPU
+	bool
+	default n
+
+config NET_DSA_MV88E6131
+	tristate "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
+	select NET_DSA_MV88E6XXX
+	select NET_DSA_MV88E6XXX_NEED_PPU
+	select NET_DSA_TAG_DSA
+	---help---
+	  This enables support for the Marvell 88E6085/6095/6095F/6131
+	  ethernet switch chips.
+
+config NET_DSA_MV88E6123_61_65
+	tristate "Marvell 88E6123/6161/6165 ethernet switch chip support"
+	select NET_DSA_MV88E6XXX
+	select NET_DSA_TAG_EDSA
+	---help---
+	  This enables support for the Marvell 88E6123/6161/6165
+	  ethernet switch chips.
+
+endmenu
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
new file mode 100644
index 0000000..f3bda05
--- /dev/null
+++ b/drivers/net/dsa/Makefile
@@ -0,0 +1,9 @@
+obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
+obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx_drv.o
+mv88e6xxx_drv-y += mv88e6xxx.o
+ifdef CONFIG_NET_DSA_MV88E6123_61_65
+mv88e6xxx_drv-y += mv88e6123_61_65.o
+endif
+ifdef CONFIG_NET_DSA_MV88E6131
+mv88e6xxx_drv-y += mv88e6131.o
+endif
diff --git a/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
similarity index 100%
rename from net/dsa/mv88e6060.c
rename to drivers/net/dsa/mv88e6060.c
diff --git a/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
similarity index 100%
rename from net/dsa/mv88e6123_61_65.c
rename to drivers/net/dsa/mv88e6123_61_65.c
diff --git a/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
similarity index 100%
rename from net/dsa/mv88e6131.c
rename to drivers/net/dsa/mv88e6131.c
diff --git a/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
similarity index 100%
rename from net/dsa/mv88e6xxx.c
rename to drivers/net/dsa/mv88e6xxx.c
diff --git a/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
similarity index 100%
rename from net/dsa/mv88e6xxx.h
rename to drivers/net/dsa/mv88e6xxx.h
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 7e12303..274791c 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -1,4 +1,4 @@
-menuconfig NET_DSA
+config NET_DSA
 	tristate "Distributed Switch Architecture support"
 	default n
 	depends on EXPERIMENTAL && NETDEVICES && !S390
@@ -23,38 +23,4 @@ config NET_DSA_TAG_TRAILER
 	bool
 	default n
 
-
-# switch drivers
-config NET_DSA_MV88E6XXX
-	tristate
-	default n
-
-config NET_DSA_MV88E6060
-	tristate "Marvell 88E6060 ethernet switch chip support"
-	select NET_DSA_TAG_TRAILER
-	---help---
-	  This enables support for the Marvell 88E6060 ethernet switch
-	  chip.
-
-config NET_DSA_MV88E6XXX_NEED_PPU
-	bool
-	default n
-
-config NET_DSA_MV88E6131
-	tristate "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
-	select NET_DSA_MV88E6XXX
-	select NET_DSA_MV88E6XXX_NEED_PPU
-	select NET_DSA_TAG_DSA
-	---help---
-	  This enables support for the Marvell 88E6085/6095/6095F/6131
-	  ethernet switch chips.
-
-config NET_DSA_MV88E6123_61_65
-	tristate "Marvell 88E6123/6161/6165 ethernet switch chip support"
-	select NET_DSA_MV88E6XXX
-	select NET_DSA_TAG_EDSA
-	---help---
-	  This enables support for the Marvell 88E6123/6161/6165
-	  ethernet switch chips.
-
 endif
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 191dd48..7b9fcbb 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -6,14 +6,3 @@ dsa_core-y += dsa.o slave.o
 dsa_core-$(CONFIG_NET_DSA_TAG_DSA) += tag_dsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
 dsa_core-$(CONFIG_NET_DSA_TAG_TRAILER) += tag_trailer.o
-
-# switch drivers
-obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
-obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx_drv.o
-mv88e6xxx_drv-y += mv88e6xxx.o
-ifdef CONFIG_NET_DSA_MV88E6123_61_65
-mv88e6xxx_drv-y += mv88e6123_61_65.o
-endif
-ifdef CONFIG_NET_DSA_MV88E6131
-mv88e6xxx_drv-y += mv88e6131.o
-endif
-- 
1.7.7.3
