From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][ATM]: [drivers] fix warnings related to readl/writel
 changes
Date: Tue, 21 Sep 2004 14:49:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921144920.7e62ca9e.davem@davemloft.net>
References: <200409212027.i8LKR2Ja010520@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200409212027.i8LKR2Ja010520@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2004 16:27:03 -0400
"chas williams (contractor)" <chas@cmf.nrl.navy.mil> wrote:

> this patch gets rid of warnings from some of the atm drivers related to
> the recent readl/writel changes.
> 
> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2004/09/17 19:50:46-04:00 chas@relax.cmf.nrl.navy.mil 
> #   [ATM]: [drivers] fix warnings related to readl/writel changes

Applied, then I added a further patch on top of this
one which uses the correct "void __iomem *" for these
things, as follows.

Thanks.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/21 14:28:56-07:00 davem@nuts.davemloft.net 
#   [ATM]: Use __iomem where appropriate.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# drivers/atm/nicstarmac.h
#   2004/09/21 14:28:23-07:00 davem@nuts.davemloft.net +1 -1
#   [ATM]: Use __iomem where appropriate.
# 
# drivers/atm/nicstar.h
#   2004/09/21 14:28:23-07:00 davem@nuts.davemloft.net +1 -1
#   [ATM]: Use __iomem where appropriate.
# 
# drivers/atm/lanai.c
#   2004/09/21 14:28:23-07:00 davem@nuts.davemloft.net +1 -1
#   [ATM]: Use __iomem where appropriate.
# 
# drivers/atm/idt77252.h
#   2004/09/21 14:28:23-07:00 davem@nuts.davemloft.net +2 -2
#   [ATM]: Use __iomem where appropriate.
# 
# drivers/atm/he.h
#   2004/09/21 14:28:23-07:00 davem@nuts.davemloft.net +1 -1
#   [ATM]: Use __iomem where appropriate.
# 
# drivers/atm/firestream.h
#   2004/09/21 14:28:23-07:00 davem@nuts.davemloft.net +1 -1
#   [ATM]: Use __iomem where appropriate.
# 
diff -Nru a/drivers/atm/firestream.h b/drivers/atm/firestream.h
--- a/drivers/atm/firestream.h	2004-09-21 14:29:53 -07:00
+++ b/drivers/atm/firestream.h	2004-09-21 14:29:53 -07:00
@@ -477,7 +477,7 @@
 	struct timer_list timer;
 
 	unsigned long hw_base;		/* mem base address */
-	void *base;             /* Mapping of base address */
+	void __iomem *base;             /* Mapping of base address */
 	int channo;
 	unsigned long channel_mask;
 
diff -Nru a/drivers/atm/he.h b/drivers/atm/he.h
--- a/drivers/atm/he.h	2004-09-21 14:29:53 -07:00
+++ b/drivers/atm/he.h	2004-09-21 14:29:53 -07:00
@@ -265,7 +265,7 @@
 struct he_dev {
 	unsigned int number;
 	unsigned int irq;
-	void *membase;
+	void __iomem *membase;
 
 	char prod_id[30];
 	char mac_addr[6];
diff -Nru a/drivers/atm/idt77252.h b/drivers/atm/idt77252.h
--- a/drivers/atm/idt77252.h	2004-09-21 14:29:53 -07:00
+++ b/drivers/atm/idt77252.h	2004-09-21 14:29:53 -07:00
@@ -355,9 +355,9 @@
 	struct pci_dev		*pcidev;	/* PCI handle (desriptor) */
 	struct atm_dev		*atmdev;	/* ATM device desriptor */
 
-	void			*membase;	/* SAR's memory base address */
+	void __iomem		*membase;	/* SAR's memory base address */
 	unsigned long		srambase;	/* SAR's sram  base address */
-	void 			*fbq[4];	/* FBQ fill addresses */
+	void __iomem		*fbq[4];	/* FBQ fill addresses */
 
 	struct semaphore	mutex;
 	spinlock_t		cmd_lock;	/* for r/w utility/sram */
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	2004-09-21 14:29:53 -07:00
+++ b/drivers/atm/lanai.c	2004-09-21 14:29:53 -07:00
@@ -191,7 +191,7 @@
 #define LANAI_EEPROM_SIZE	(128)
 
 typedef int vci_t;
-typedef void *bus_addr_t;
+typedef void __iomem *bus_addr_t;
 
 /* DMA buffer in host memory for TX, RX, or service list. */
 struct lanai_buffer {
diff -Nru a/drivers/atm/nicstar.h b/drivers/atm/nicstar.h
--- a/drivers/atm/nicstar.h	2004-09-21 14:29:53 -07:00
+++ b/drivers/atm/nicstar.h	2004-09-21 14:29:53 -07:00
@@ -763,7 +763,7 @@
 {
    int index;				/* Card ID to the device driver */
    int sram_size;			/* In k x 32bit words. 32 or 128 */
-   void *membase;			/* Card's memory base address */
+   void __iomem *membase;		/* Card's memory base address */
    unsigned long max_pcr;
    int rct_size;			/* Number of entries */
    int vpibits;
diff -Nru a/drivers/atm/nicstarmac.h b/drivers/atm/nicstarmac.h
--- a/drivers/atm/nicstarmac.h	2004-09-21 14:29:53 -07:00
+++ b/drivers/atm/nicstarmac.h	2004-09-21 14:29:53 -07:00
@@ -7,7 +7,7 @@
  ******************************************************************************/
 
 
-typedef void * virt_addr_t;
+typedef void __iomem *virt_addr_t;
 
 u_int32_t nicstar_read_eprom_status( virt_addr_t base );
 void nicstar_init_eprom( virt_addr_t base );
