From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH/RFC] make MII and PHYLIB independent of NET_ETHERNET
Date: Sat, 2 Dec 2006 15:43:45 -0800
Message-ID: <20061202154345.fb3b4b6a.randy.dunlap@oracle.com>
References: <20061119202249.f0acb41c.randy.dunlap@oracle.com>
	<456EBC16.8050006@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:23264 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S936590AbWLBXnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 18:43:11 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <456EBC16.8050006@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Nov 2006 06:10:14 -0500 Jeff Garzik wrote:

> ACK, but patch doesn't apply to #upstream

Does it work to patch -mm instead?  (below)

---
From: Randy Dunlap <randy.dunlap@oracle.com>

PHYLIB can be used by non-NET_ETHERNET (10/100 ethernet) devices;
e.g., GIANFAR (gigabit) uses it.

We also have USB ethernet devices trying to use MII
without NET_ETHERNET being enabled, so move MII outside of
NET_ETHERNET, along with PHYLIB.

They both still depend on NET && NETDEVICES.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig     |   16 ++++++++--------
 drivers/net/phy/Kconfig |   21 +++++----------------
 2 files changed, 13 insertions(+), 24 deletions(-)

--- linux-2.6.19-rc6-mm2.orig/drivers/net/Kconfig
+++ linux-2.6.19-rc6-mm2/drivers/net/Kconfig
@@ -145,6 +145,14 @@ config NET_SB1000
 
 source "drivers/net/arcnet/Kconfig"
 
+config MII
+	tristate "Generic Media Independent Interface device support"
+	depends on NET_ETHERNET
+	help
+	  Most ethernet controllers have MII transceiver either as an external
+	  or internal device.  It is safe to say Y or M here even if your
+	  ethernet card lack MII.
+
 source "drivers/net/phy/Kconfig"
 
 #
@@ -180,14 +188,6 @@ config NET_ETHERNET
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
 config MACB
 	tristate "Atmel MACB support"
 	depends on NET_ETHERNET && AVR32
--- linux-2.6.19-rc6-mm2.orig/drivers/net/phy/Kconfig
+++ linux-2.6.19-rc6-mm2/drivers/net/phy/Kconfig
@@ -2,69 +2,59 @@
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
 
 config BROADCOM_PHY
 	tristate "Drivers for Broadcom PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the BCM5411, BCM5421 and BCM5461 PHYs.
 
 config FIXED_PHY
 	tristate "Drivers for PHY emulation on fixed speed/link"
-	depends on PHYLIB
 	---help---
 	  Adds the driver to PHY layer to cover the boards that do not have any PHY bound,
 	  but with the ability to manipulate with speed/link in software. The relavant MII
@@ -79,5 +69,4 @@ config FIXED_MII_100_FDX
 	bool "Emulation for 100M Fdx fixed PHY behavior"
 	depends on FIXED_PHY
 
-endmenu
-
+endif #PHYLIB
