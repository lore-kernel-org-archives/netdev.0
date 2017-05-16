From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/2] drivers: net: DSA: Sort drivers
Date: Tue, 16 May 2017 22:40:08 +0200
Message-ID: <1494967208-11550-3-git-send-email-andrew@lunn.ch>
References: <1494967208-11550-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60832 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751344AbdEPUkk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 16:40:40 -0400
In-Reply-To: <1494967208-11550-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With more drivers being added, it is time to sort the drivers to
impose some order.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/Kconfig  | 40 ++++++++++++++++++++--------------------
 drivers/net/dsa/Makefile |  6 +++---
 2 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 862ee22303c2..68131a45ac5e 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -1,13 +1,7 @@
 menu "Distributed Switch Architecture drivers"
 	depends on HAVE_NET_DSA
 
-config NET_DSA_MV88E6060
-	tristate "Marvell 88E6060 ethernet switch chip support"
-	depends on NET_DSA
-	select NET_DSA_TAG_TRAILER
-	---help---
-	  This enables support for the Marvell 88E6060 ethernet switch
-	  chip.
+source "drivers/net/dsa/b53/Kconfig"
 
 config NET_DSA_BCM_SF2
 	tristate "Broadcom Starfighter 2 Ethernet switch support"
@@ -21,19 +15,6 @@ config NET_DSA_BCM_SF2
 	  This enables support for the Broadcom Starfighter 2 Ethernet
 	  switch chips.
 
-source "drivers/net/dsa/b53/Kconfig"
-
-source "drivers/net/dsa/mv88e6xxx/Kconfig"
-
-config NET_DSA_QCA8K
-	tristate "Qualcomm Atheros QCA8K Ethernet switch family support"
-	depends on NET_DSA
-	select NET_DSA_TAG_QCA
-	select REGMAP
-	---help---
-	  This enables support for the Qualcomm Atheros QCA8K Ethernet
-	  switch chips.
-
 config NET_DSA_LOOP
 	tristate "DSA mock-up Ethernet switch chip support"
 	depends on NET_DSA
@@ -50,6 +31,25 @@ config NET_DSA_MT7530
 	  This enables support for the Mediatek MT7530 Ethernet switch
 	  chip.
 
+config NET_DSA_MV88E6060
+	tristate "Marvell 88E6060 ethernet switch chip support"
+	depends on NET_DSA
+	select NET_DSA_TAG_TRAILER
+	---help---
+	  This enables support for the Marvell 88E6060 ethernet switch
+	  chip.
+
+source "drivers/net/dsa/mv88e6xxx/Kconfig"
+
+config NET_DSA_QCA8K
+	tristate "Qualcomm Atheros QCA8K Ethernet switch family support"
+	depends on NET_DSA
+	select NET_DSA_TAG_QCA
+	select REGMAP
+	---help---
+	  This enables support for the Qualcomm Atheros QCA8K Ethernet
+	  switch chips.
+
 config NET_DSA_SMSC_LAN9303
 	tristate
 	select NET_DSA_TAG_LAN9303
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index edd630361736..9613f36083a6 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,11 +1,11 @@
-obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
 obj-$(CONFIG_NET_DSA_BCM_SF2)	+= bcm-sf2.o
 bcm-sf2-objs			:= bcm_sf2.o bcm_sf2_cfp.o
-obj-$(CONFIG_NET_DSA_QCA8K)	+= qca8k.o
+obj-$(CONFIG_NET_DSA_LOOP)	+= dsa_loop.o dsa_loop_bdinfo.o
 obj-$(CONFIG_NET_DSA_MT7530)	+= mt7530.o
+obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
+obj-$(CONFIG_NET_DSA_QCA8K)	+= qca8k.o
 obj-$(CONFIG_NET_DSA_SMSC_LAN9303) += lan9303-core.o
 obj-$(CONFIG_NET_DSA_SMSC_LAN9303_I2C) += lan9303_i2c.o
 obj-$(CONFIG_NET_DSA_SMSC_LAN9303_MDIO) += lan9303_mdio.o
 obj-y				+= b53/
 obj-y				+= mv88e6xxx/
-obj-$(CONFIG_NET_DSA_LOOP)	+= dsa_loop.o dsa_loop_bdinfo.o
-- 
2.11.0
