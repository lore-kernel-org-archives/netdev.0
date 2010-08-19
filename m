From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] isdn/avm: fix build when PCMCIA is not enabled
Date: Thu, 19 Aug 2010 10:07:23 -0700
Message-ID: <20100819100723.d0c0578e.randy.dunlap@oracle.com>
References: <20100819143941.d3ea5cb4.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Carsten Paeth <calle@calle.de>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100819143941.d3ea5cb4.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Why wouldn't kconfig symbol ISDN_DRV_AVMB1_B1PCMCIA also depend on
PCMCIA?

Fix build for PCMCIA not enabled:

ERROR: "b1_free_card" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!
ERROR: "b1ctl_proc_fops" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!
ERROR: "b1_reset_ctr" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!
ERROR: "b1_load_firmware" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!
ERROR: "b1_send_message" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!
ERROR: "b1_release_appl" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!
ERROR: "b1_register_appl" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!
ERROR: "b1_getrevision" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!
ERROR: "b1_detect" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!
ERROR: "b1_interrupt" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!
ERROR: "b1_alloc_card" [drivers/isdn/hardware/avm/b1pcmcia.ko] undefined!

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Carsten Paeth <calle@calle.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
---
 drivers/isdn/hardware/avm/Kconfig |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-next-20100819.orig/drivers/isdn/hardware/avm/Kconfig
+++ linux-next-20100819/drivers/isdn/hardware/avm/Kconfig
@@ -36,12 +36,13 @@ config ISDN_DRV_AVMB1_T1ISA
 
 config ISDN_DRV_AVMB1_B1PCMCIA
 	tristate "AVM B1/M1/M2 PCMCIA support"
+	depends on PCMCIA
 	help
 	  Enable support for the PCMCIA version of the AVM B1 card.
 
 config ISDN_DRV_AVMB1_AVM_CS
 	tristate "AVM B1/M1/M2 PCMCIA cs module"
-	depends on ISDN_DRV_AVMB1_B1PCMCIA && PCMCIA
+	depends on ISDN_DRV_AVMB1_B1PCMCIA
 	help
 	  Enable the PCMCIA client driver for the AVM B1/M1/M2
 	  PCMCIA cards.
