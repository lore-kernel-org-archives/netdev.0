From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 06/11] m68k/atari: Change VME irq numbers from unsigned long to unsigned int
Date: Wed, 21 Mar 2012 10:51:50 +0100
Message-ID: <1332323515-7314-6-git-send-email-geert@linux-m68k.org>
References: <1332323515-7314-1-git-send-email-geert@linux-m68k.org>
Cc: linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org
To: linux-m68k@lists.linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332323515-7314-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Device interrupts numbers were changed to unsigned int in 1997, the year
IRQ_MACHSPEC was killed as well.

Also kill a related cast while we're at it.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: netdev@vger.kernel.org
---
 arch/m68k/atari/ataints.c             |    4 ++--
 arch/m68k/include/asm/atariints.h     |    4 ++--
 drivers/net/ethernet/amd/atarilance.c |   11 ++++-------
 3 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/arch/m68k/atari/ataints.c b/arch/m68k/atari/ataints.c
index 8048e1b..54807d5 100644
--- a/arch/m68k/atari/ataints.c
+++ b/arch/m68k/atari/ataints.c
@@ -207,7 +207,7 @@ void __init atari_init_IRQ(void)
  * hardware with a programmable int vector (probably a VME board).
  */
 
-unsigned long atari_register_vme_int(void)
+unsigned int atari_register_vme_int(void)
 {
 	int i;
 
@@ -224,7 +224,7 @@ unsigned long atari_register_vme_int(void)
 EXPORT_SYMBOL(atari_register_vme_int);
 
 
-void atari_unregister_vme_int(unsigned long irq)
+void atari_unregister_vme_int(unsigned int irq)
 {
 	if (irq >= VME_SOURCE_BASE && irq < VME_SOURCE_BASE + VME_MAX_SOURCES) {
 		irq -= VME_SOURCE_BASE;
diff --git a/arch/m68k/include/asm/atariints.h b/arch/m68k/include/asm/atariints.h
index 656bbbf..5fc13bd 100644
--- a/arch/m68k/include/asm/atariints.h
+++ b/arch/m68k/include/asm/atariints.h
@@ -198,7 +198,7 @@ static inline int atari_irq_pending( unsigned irq )
 	return( get_mfp_bit( irq, MFP_PENDING ) );
 }
 
-unsigned long atari_register_vme_int( void );
-void atari_unregister_vme_int( unsigned long );
+unsigned int atari_register_vme_int(void);
+void atari_unregister_vme_int(unsigned int);
 
 #endif /* linux/atariints.h */
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index 15bfa28..20a4f6d 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -558,21 +558,18 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 			printk( "Lance: request for irq %d failed\n", IRQ_AUTO_5 );
 			return 0;
 		}
-		dev->irq = (unsigned short)IRQ_AUTO_5;
+		dev->irq = IRQ_AUTO_5;
 	}
 	else {
-		/* For VME-RieblCards, request a free VME int;
-		 * (This must be unsigned long, since dev->irq is short and the
-		 * IRQ_MACHSPEC bit would be cut off...)
-		 */
-		unsigned long irq = atari_register_vme_int();
+		/* For VME-RieblCards, request a free VME int */
+		unsigned int irq = atari_register_vme_int();
 		if (!irq) {
 			printk( "Lance: request for VME interrupt failed\n" );
 			return 0;
 		}
 		if (request_irq(irq, lance_interrupt, IRQ_TYPE_PRIO,
 		            "Riebl-VME Ethernet", dev)) {
-			printk( "Lance: request for irq %ld failed\n", irq );
+			printk( "Lance: request for irq %u failed\n", irq );
 			return 0;
 		}
 		dev->irq = irq;
-- 
1.7.0.4
