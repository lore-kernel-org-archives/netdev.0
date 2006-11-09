From: Olaf Hering <olaf@aepfle.de>
Subject: [PATCH] mark non-compiling ISA network drivers i386 only
Date: Thu, 9 Nov 2006 19:40:21 +0100 (MET)
Message-ID: <20061109184021.GA25691@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.190]:52306 "EHLO
	mo-p07-ob.rzone.de") by vger.kernel.org with ESMTP id S1753357AbWKISmg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 13:42:36 -0500
To: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Provide drivers for the old toys only on i386
isa_bus_to_virt is defined only on i386, mips and arm
isa_virt_to_bus is used for floppy.ko

Add missing '&& ISA_DMA_API' to NI52

WARNING: "isa_bus_to_virt" [drivers/net/ni65.ko] undefined!
WARNING: "isa_virt_to_bus" [drivers/net/ni65.ko] undefined!
WARNING: "isa_bus_to_virt" [drivers/net/ni52.ko] undefined!
WARNING: "isa_bus_to_virt" [drivers/net/lance.ko] undefined!
WARNING: "isa_virt_to_bus" [drivers/net/lance.ko] undefined!
WARNING: "isa_bus_to_virt" [drivers/net/3c515.ko] undefined!
WARNING: "isa_virt_to_bus" [drivers/net/3c515.ko] undefined!
WARNING: "isa_virt_to_bus" [drivers/net/3c505.ko] undefined!

I'm sure noone will miss the drivers.

Signed-off-by: Olaf Hering <olaf@aepfle.de>

---
 drivers/net/Kconfig |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/net/Kconfig
===================================================================
--- linux-2.6.orig/drivers/net/Kconfig
+++ linux-2.6/drivers/net/Kconfig
@@ -616,7 +616,7 @@ config EL2
 
 config ELPLUS
 	tristate "3c505 \"EtherLink Plus\" support"
-	depends on NET_VENDOR_3COM && ISA && ISA_DMA_API
+	depends on NET_VENDOR_3COM && ISA && ISA_DMA_API && X86
 	---help---
 	  Information about this network (Ethernet) card can be found in
 	  <file:Documentation/networking/3c505.txt>.  If you have a card of
@@ -657,7 +657,7 @@ config EL3
 
 config 3C515
 	tristate "3c515 ISA \"Fast EtherLink\""
-	depends on NET_VENDOR_3COM && (ISA || EISA) && ISA_DMA_API
+	depends on NET_VENDOR_3COM && (ISA || EISA) && ISA_DMA_API && X86
 	help
 	  If you have a 3Com ISA EtherLink XL "Corkscrew" 3c515 Fast Ethernet
 	  network card, say Y and read the Ethernet-HOWTO, available from
@@ -735,7 +735,7 @@ config TYPHOON
 
 config LANCE
 	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
-	depends on NET_ETHERNET && ISA && ISA_DMA_API
+	depends on NET_ETHERNET && ISA && ISA_DMA_API && X86
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -918,7 +918,7 @@ config NI5010
 
 config NI52
 	tristate "NI5210 support"
-	depends on NET_VENDOR_RACAL && ISA
+	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API && X86
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -930,7 +930,7 @@ config NI52
 
 config NI65
 	tristate "NI6510 support"
-	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API
+	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API && X86
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
