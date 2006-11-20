From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH/RFC] make MII and PHYLIB independent of NET_ETHERNET
Date: Sun, 19 Nov 2006 20:22:49 -0800
Message-ID: <20061119202249.f0acb41c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:20547 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S933915AbWKTEZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 23:25:16 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

PHYLIB can be used by non-NET_ETHERNET (10/100 ethernet) devices;
e.g., GIANFAR (gigabit) uses it.

We also have USB ethernet devices trying to use MII
without NET_ETHERNET being enabled, so move MII outside of
NET_ETHERNET, along with PHYLIB.

They both still depend on NET && NETDEVICES.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig     |   15 +++++++--------
 drivers/net/phy/Kconfig |   19 +++++--------------
 2 files changed, 12 insertions(+), 22 deletions(-)

--- linux-2619-rc6g2.orig/drivers/net/Kconfig
+++ linux-2619-rc6g2/drivers/net/Kconfig
@@ -145,6 +145,13 @@ config NET_SB1000
 
 source "drivers/net/arcnet/Kconfig"
 
+config MII
+	tristate "Generic Media Independent Interface device support"
+	help
+	  Most ethernet controllers have MII transceiver either as an external
+	  or internal device.  It is safe to say Y or M here even if your
+	  ethernet card lack MII.
+
 source "drivers/net/phy/Kconfig"
 
 #
@@ -180,14 +187,6 @@ config NET_ETHERNET
 	  kernel: saying N will just cause the configurator to skip all
 	  the questions about Ethernet network cards. If unsure, say N.
 
-config MII
-	tristate "Generic Media Independent Interface device support"
-	depends on NET_ETHERNET
-	help
-	  Most ethernet controllers have MII transceiver either as an external
-	  or internal device.  It is safe to say Y or M here even if your
-	  ethernet card lack MII.
-
 source "drivers/net/arm/Kconfig"
 
 config MACE
--- linux-2619-rc6g2.orig/drivers/net/phy/Kconfig
+++ linux-2619-rc6g2/drivers/net/phy/Kconfig
@@ -2,63 +2,54 @@
 # PHY Layer Configuration
 #
 
-menu "PHY device support"
-
-config PHYLIB
+menuconfig PHYLIB
 	tristate "PHY Device support and infrastructure"
-	depends on NET_ETHERNET && (BROKEN || !S390)
+	depends on (BROKEN || !S390)
 	help
 	  Ethernet controllers are usually attached to PHY
 	  devices.  This option provides infrastructure for
 	  managing PHY devices.
 
+if PHYLIB
+
 comment "MII PHY device drivers"
-	depends on PHYLIB
 
 config MARVELL_PHY
 	tristate "Drivers for Marvell PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently has a driver for the 88E1011S
 	
 config DAVICOM_PHY
 	tristate "Drivers for Davicom PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports dm9161e and dm9131
 
 config QSEMI_PHY
 	tristate "Drivers for Quality Semiconductor PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the qs6612
 
 config LXT_PHY
 	tristate "Drivers for the Intel LXT PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the lxt970, lxt971
 
 config CICADA_PHY
 	tristate "Drivers for the Cicada PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the cis8204
 config VITESSE_PHY
         tristate "Drivers for the Vitesse PHYs"
-        depends on PHYLIB
         ---help---
           Currently supports the vsc8244
 
 config SMSC_PHY
 	tristate "Drivers for SMSC PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the LAN83C185 PHY
 
 config FIXED_PHY
 	tristate "Drivers for PHY emulation on fixed speed/link"
-	depends on PHYLIB
 	---help---
 	  Adds the driver to PHY layer to cover the boards that do not have any PHY bound,
 	  but with the ability to manipulate with speed/link in software. The relavant MII
@@ -73,5 +64,5 @@ config FIXED_MII_100_FDX
 	bool "Emulation for 100M Fdx fixed PHY behavior"
 	depends on FIXED_PHY
 
-endmenu
+endif #PHYLIB
 


---
