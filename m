From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: [PATCH 22/36] Use menuconfig objects II - netdev/pcmcia
Date: Mon, 30 Apr 2007 13:45:03 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0704301344100.29151@yvahk01.tjqt.qr>
References: <Pine.LNX.4.61.0704301225060.29151@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <Pine.LNX.4.61.0704301225060.29151@yvahk01.tjqt.qr>
List-Unsubscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: linux-pcmcia-bounces@lists.infradead.org
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


Change Kconfig objects from "menu, config" into "menuconfig" so
that the user can disable the whole feature without having to
enter the menu first.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>

---
 drivers/net/pcmcia/Kconfig |   23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

--- linux-2.6.21-mm_20070428.orig/drivers/net/pcmcia/Kconfig
+++ linux-2.6.21-mm_20070428/drivers/net/pcmcia/Kconfig
@@ -2,11 +2,9 @@
 # PCMCIA Network device configuration
 #
 
-menu "PCMCIA network device support"
-	depends on NETDEVICES && PCMCIA!=n
-
-config NET_PCMCIA
+menuconfig NET_PCMCIA
 	bool "PCMCIA network device support"
+	depends on PCMCIA
 	---help---
 	  Say Y if you would like to include support for any PCMCIA or CardBus
 	  network adapters, then say Y to the driver for your particular card
@@ -21,9 +19,10 @@ config NET_PCMCIA
 
 	  If unsure, say N.
 
+if NET_PCMCIA
+
 config PCMCIA_3C589
 	tristate "3Com 3c589 PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	help
 	  Say Y here if you intend to attach a 3Com 3c589 or compatible PCMCIA
 	  (PC-card) Ethernet card to your computer.
@@ -33,7 +32,6 @@ config PCMCIA_3C589
 
 config PCMCIA_3C574
 	tristate "3Com 3c574 PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	help
 	  Say Y here if you intend to attach a 3Com 3c574 or compatible PCMCIA
 	  (PC-card) Fast Ethernet card to your computer.
@@ -43,7 +41,6 @@ config PCMCIA_3C574
 
 config PCMCIA_FMVJ18X
 	tristate "Fujitsu FMV-J18x PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	select CRC32
 	help
 	  Say Y here if you intend to attach a Fujitsu FMV-J18x or compatible
@@ -54,7 +51,6 @@ config PCMCIA_FMVJ18X
 
 config PCMCIA_PCNET
 	tristate "NE2000 compatible PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	select CRC32
 	help
 	  Say Y here if you intend to attach an NE2000 compatible PCMCIA
@@ -65,7 +61,6 @@ config PCMCIA_PCNET
 
 config PCMCIA_NMCLAN
 	tristate "New Media PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	help
 	  Say Y here if you intend to attach a New Media Ethernet or LiveWire
 	  PCMCIA (PC-card) Ethernet card to your computer.
@@ -75,7 +70,6 @@ config PCMCIA_NMCLAN
 
 config PCMCIA_SMC91C92
 	tristate "SMC 91Cxx PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	select CRC32
 	select MII
 	help
@@ -87,7 +81,6 @@ config PCMCIA_SMC91C92
 
 config PCMCIA_XIRC2PS
 	tristate "Xircom 16-bit PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	help
 	  Say Y here if you intend to attach a Xircom 16-bit PCMCIA (PC-card)
 	  Ethernet or Fast Ethernet card to your computer.
@@ -97,7 +90,6 @@ config PCMCIA_XIRC2PS
 
 config PCMCIA_AXNET
 	tristate "Asix AX88190 PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	---help---
 	  Say Y here if you intend to attach an Asix AX88190-based PCMCIA
 	  (PC-card) Fast Ethernet card to your computer.  These cards are
@@ -109,7 +101,7 @@ config PCMCIA_AXNET
 
 config ARCNET_COM20020_CS
 	tristate "COM20020 ARCnet PCMCIA support"
-	depends on NET_PCMCIA && ARCNET_COM20020 && PCMCIA
+	depends on ARCNET_COM20020
 	help
 	  Say Y here if you intend to attach this type of ARCnet PCMCIA card
 	  to your computer.
@@ -119,7 +111,7 @@ config ARCNET_COM20020_CS
 
 config PCMCIA_IBMTR
 	tristate "IBM PCMCIA tokenring adapter support"
-	depends on NET_PCMCIA && IBMTR!=y && TR && PCMCIA && !64BIT
+	depends on IBMTR!=y && TR && !64BIT
 	help
 	  Say Y here if you intend to attach this type of Token Ring PCMCIA
 	  card to your computer. You then also need to say Y to "Token Ring
@@ -128,5 +120,4 @@ config PCMCIA_IBMTR
 	  To compile this driver as a module, choose M here: the module will be
 	  called ibmtr_cs.
 
-endmenu
-
+endif # NET_PCMCIA
