From: Domenico Andreoli <cavokz@gmail.com>
Subject: Re: [PATCH 2/2] ARM: QQ2440 networking support
Date: Thu, 3 Feb 2011 11:34:13 +0100
Message-ID: <20110203103413.GA7276@vixen>
References: <20110202220359.GA2808@dandreoli.com>
	<20110202220530.GB2808@dandreoli.com>
	<20110202220637.GC2808@dandreoli.com>
	<20110203094123.GB3141@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kukjin Kim <kgene.kim@samsung.com>,
	Russell King <linux@arm.linux.org.uk>, Ben Dooks <ben-linux@fluff.org>,
	linux-arm-kernel@lists.infradead.org
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20110203094123.GB3141@pulham.picochip.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 03, 2011 at 09:41:23AM +0000, Jamie Iles wrote:
> Hi Domenico,

Hi Jamie,

> This should probably also go to the netdev mailing list: 
> netdev@vger.kernel.org.  A couple of other minor comments inline.

CCed them

> On Wed, Feb 02, 2011 at 10:06:37PM +0000, Domenico Andreoli wrote:
> > From: Domenico Andreoli <cavokz@gmail.com>
> > 
> > Add networking support for QQ2440.
> > 
> > Signed-off-by: Domenico Andreoli <cavokz@gmail.com>
> > 
> > ---
> >  arch/arm/mach-s3c2440/include/mach/qq2440.h |   22 ++++++++++++
> >  arch/arm/mach-s3c2440/mach-qq2440.c         |   16 ++++++++
> >  drivers/net/Kconfig                         |    4 +-
> >  drivers/net/cs89x0.c                        |   33 ++++++++++++------
> >  4 files changed, 61 insertions(+), 14 deletions(-)
> > 
> > Index: arm-2.6.git/arch/arm/mach-s3c2440/include/mach/qq2440.h
> > ===================================================================
> > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > +++ arm-2.6.git/arch/arm/mach-s3c2440/include/mach/qq2440.h	2011-02-02 18:32:38.000000000 +0000
> > @@ -0,0 +1,22 @@
> > +/*
> > + * arch/arm/mach-s3c2440/include/mach/qq2440.h
> > + *
> > + * Copyright (c) 2011 Domenico Andreoli <cavokz@gmail.com>
> > + *
> > + * QQ2440 - platform definitions
> > + *
> > + * This program is free software; you can redistribute it and/or modify
> > + * it under the terms of the GNU General Public License version 2 as
> > + * published by the Free Software Foundation.
> > +*/
> > +
> > +#ifndef __ASM_MACH_QQ2440_H
> > +#define __ASM_MACH_QQ2440_H
> > +
> > +#define QQ2440_CS8900_IRQ         IRQ_EINT9
> > +
> > +#define QQ2440_CS8900_VIRT_BASE   S3C_ADDR(0x00500000)
> > +#define QQ2440_CS8900_PA          (S3C2410_CS3 + 0x1000000)
> > +#define QQ2440_CS8900_SZ          SZ_1M
> > +
> > +#endif /* __ASM_MACH_QQ2440_H */
> > Index: arm-2.6.git/drivers/net/cs89x0.c
> > ===================================================================
> > --- arm-2.6.git.orig/drivers/net/cs89x0.c	2011-02-02 18:28:01.000000000 +0000
> > +++ arm-2.6.git/drivers/net/cs89x0.c	2011-02-02 18:32:38.000000000 +0000
> > @@ -95,6 +95,9 @@
> >    Dmitry Pervushin  : dpervushin@ru.mvista.com
> >                      : PNX010X platform support
> >  
> > +  Domenico Andreoli : cavokz@gmail.com
> > +                    : QQ2440 platform support
> > +
> >  */
> >  
> >  /* Always include 'config.h' first in case the user wants to turn on
> > @@ -117,7 +120,7 @@
> >   * Set this to zero to remove all the debug statements via
> >   * dead code elimination
> >   */
> > -#define DEBUGGING	1
> > +#define DEBUGGING	0
> 
> This is probably best split out as a separate patch.

I will

> >  /*
> >    Sources:
> > @@ -173,6 +176,10 @@
> >  #if defined(CONFIG_MACH_IXDP2351)
> >  static unsigned int netcard_portlist[] __used __initdata = {IXDP2351_VIRT_CS8900_BASE, 0};
> >  static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
> > +#elif defined(CONFIG_MACH_QQ2440)
> > +#include <mach/qq2440.h>
> > +static unsigned int netcard_portlist[] __used __initdata = {QQ2440_CS8900_VIRT_BASE + 0x300, 0};
> > +static unsigned int cs8900_irq_map[] = {QQ2440_CS8900_IRQ, 0, 0, 0};
> >  #elif defined(CONFIG_ARCH_IXDP2X01)
> >  static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
> >  static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
> > @@ -521,6 +528,10 @@
> >  #endif
> >  		lp->force = g_cs89x0_media__force;
> >  #endif
> > +
> > +#if defined(CONFIG_MACH_QQ2440)
> > +		lp->force |= FORCE_RJ45 | FORCE_FULL;
> > +#endif
> >          }
> >  
> >  	/* Grab the region so we can find another board if autoIRQ fails. */
> > @@ -608,7 +619,7 @@
> >  		        dev->dev_addr[i*2+1] = Addr >> 8;
> >  		}
> >  
> > -	   	/* Load the Adapter Configuration.
> > +		/* Load the Adapter Configuration.
> >  		   Note:  Barring any more specific information from some
> >  		   other source (ie EEPROM+Schematics), we would not know
> >  		   how to operate a 10Base2 interface on the AUI port.
> > @@ -655,7 +666,7 @@
> >  	if ((readreg(dev, PP_SelfST) & EEPROM_PRESENT) == 0)
> >  		printk(KERN_WARNING "cs89x0: No EEPROM, relying on command line....\n");
> >  	else if (get_eeprom_data(dev, START_EEPROM_DATA,CHKSUM_LEN,eeprom_buff) < 0) {
> > -		printk(KERN_WARNING "\ncs89x0: EEPROM read failed, relying on command line.\n");
> > +		printk(KERN_WARNING "cs89x0: EEPROM read failed, relying on command line.\n");
> >          } else if (get_eeprom_cksum(START_EEPROM_DATA,CHKSUM_LEN,eeprom_buff) < 0) {
> >  		/* Check if the chip was able to read its own configuration starting
> >  		   at 0 in the EEPROM*/
> > @@ -709,7 +720,7 @@
> >          /* FIXME: we don't set the Ethernet address on the command line.  Use
> >             ifconfig IFACE hw ether AABBCCDDEEFF */
> >  
> > -	printk(KERN_INFO "cs89x0 media %s%s%s",
> > +	printk(KERN_INFO "cs89x0: media %s%s%s",
> >  	       (lp->adapter_cnf & A_CNF_10B_T)?"RJ-45,":"",
> >  	       (lp->adapter_cnf & A_CNF_AUI)?"AUI,":"",
> >  	       (lp->adapter_cnf & A_CNF_10B_2)?"BNC,":"");
> 
> Splitting these cleanups into a cleanup patch would be handly so you can 
> see the real changes easier.

generally speaking, this driver requires some care. it's not only
about formatting.

you can see the ifdefs I had to add for QQ2440. you can note also that
it's not possible to compile it for multiple platforms because there
would be multiple definitions of some symbols.

for instance, there is a design bug on the QQ2440. EEPROM is not present
but the CS8900 is not correctly wired and EEPROM is incorrectly supposed
to be present. one way to solve this is with some more ifdefs...

in practice I'm volunteering to switch it to some more modern model like
platform driver but i still need to understand if it has any sense. it
does not seem a popular driver and I doubt there will be so many new
boards requiring it that the work could be justified (but I would do
it anyway).

what do netdev people think?

> > @@ -943,7 +954,7 @@
> >  static void __init reset_chip(struct net_device *dev)
> >  {
> >  #if !defined(CONFIG_MACH_MX31ADS)
> > -#if !defined(CONFIG_MACH_IXDP2351) && !defined(CONFIG_ARCH_IXDP2X01)
> > +#if !defined(CS89x0_NONISA_IRQ)
> >  	struct net_local *lp = netdev_priv(dev);
> >  	int ioaddr = dev->base_addr;
> >  #endif
> > @@ -954,18 +965,18 @@
> >  	/* wait 30 ms */
> >  	msleep(30);
> >  
> > -#if !defined(CONFIG_MACH_IXDP2351) && !defined(CONFIG_ARCH_IXDP2X01)
> > +#if !defined(CS89x0_NONISA_IRQ)
> >  	if (lp->chip_type != CS8900) {
> >  		/* Hardware problem requires PNP registers to be reconfigured after a reset */
> >  		writeword(ioaddr, ADD_PORT, PP_CS8920_ISAINT);
> > -		outb(dev->irq, ioaddr + DATA_PORT);
> > -		outb(0,      ioaddr + DATA_PORT + 1);
> > +		writeword(ioaddr, DATA_PORT, dev->irq);
> > +		writeword(ioaddr, DATA_PORT + 1, 0);
> >  
> >  		writeword(ioaddr, ADD_PORT, PP_CS8920_ISAMemB);
> > -		outb((dev->mem_start >> 16) & 0xff, ioaddr + DATA_PORT);
> > -		outb((dev->mem_start >> 8) & 0xff,   ioaddr + DATA_PORT + 1);
> > +		writeword(ioaddr, DATA_PORT, (dev->mem_start >> 16) & 0xff);
> > +		writeword(ioaddr, DATA_PORT + 1, (dev->mem_start >> 8) & 0xff);
> >  	}
> > -#endif	/* IXDP2x01 */
> > +#endif
> >  
> >  	/* Wait until the chip is reset */
> >  	reset_start_time = jiffies;
> > Index: arm-2.6.git/drivers/net/Kconfig
> > ===================================================================
> > --- arm-2.6.git.orig/drivers/net/Kconfig	2011-02-02 18:28:01.000000000 +0000
> > +++ arm-2.6.git/drivers/net/Kconfig	2011-02-02 18:32:38.000000000 +0000
> > @@ -1498,7 +1498,7 @@
> >  config CS89x0
> >  	tristate "CS89x0 support"
> >  	depends on NET_ETHERNET && (ISA || EISA || MACH_IXDP2351 \
> > -		|| ARCH_IXDP2X01 || MACH_MX31ADS)
> > +		|| ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440)
> >  	---help---
> >  	  Support for CS89x0 chipset based Ethernet cards. If you have a
> >  	  network (Ethernet) card of this type, say Y and read the
> > @@ -1512,7 +1512,7 @@
> >  config CS89x0_NONISA_IRQ
> >  	def_bool y
> >  	depends on CS89x0 != n
> > -	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS
> > +	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440
> >  
> >  config TC35815
> >  	tristate "TOSHIBA TC35815 Ethernet support"
> > Index: arm-2.6.git/arch/arm/mach-s3c2440/mach-qq2440.c
> > ===================================================================
> > --- arm-2.6.git.orig/arch/arm/mach-s3c2440/mach-qq2440.c	2011-02-02 18:29:48.000000000 +0000
> > +++ arm-2.6.git/arch/arm/mach-s3c2440/mach-qq2440.c	2011-02-02 18:32:38.000000000 +0000
> > @@ -36,6 +36,7 @@
> >  #include <mach/leds-gpio.h>
> >  #include <mach/regs-mem.h>
> >  #include <mach/irqs.h>
> > +#include <mach/qq2440.h>
> >  #include <plat/nand.h>
> >  #include <plat/iic.h>
> >  #include <plat/mci.h>
> > @@ -54,7 +55,12 @@
> >  #include <sound/s3c24xx_uda134x.h>
> >  
> >  static struct map_desc qq2440_iodesc[] __initdata = {
> > -	/* nothing to declare, move along */
> > +	{
> > +		.virtual  = QQ2440_CS8900_VIRT_BASE,
> > +		.pfn      = __phys_to_pfn(QQ2440_CS8900_PA),
> > +		.length   = QQ2440_CS8900_SZ,
> > +		.type     = MT_DEVICE
> > +	}
> >  };
> >  
> >  #define UCON S3C2410_UCON_DEFAULT
> > @@ -325,10 +331,18 @@
> >  	s3c24xx_init_uarts(qq2440_uartcfgs, ARRAY_SIZE(qq2440_uartcfgs));
> >  }
> >  
> > +#define QQ2440_CS8900_BANKCON  (S3C2410_BANKCON_Tacp6 | S3C2410_BANKCON_Tcah4 | S3C2410_BANKCON_Tcoh1 | \
> > +                                S3C2410_BANKCON_Tacc14 | S3C2410_BANKCON_Tcos4)
> > +
> >  static void __init qq2440_init(void)
> >  {
> >  	int i;
> >  
> > +	/* Ethernet */
> > +	__raw_writel(__raw_readl(S3C2410_BWSCON) | S3C2410_BWSCON_WS3 | S3C2410_BWSCON_ST3, S3C2410_BWSCON);
> > +	__raw_writel(QQ2440_CS8900_BANKCON, S3C2410_BANKCON3);
> > +	set_irq_type(QQ2440_CS8900_IRQ, IRQ_TYPE_EDGE_RISING);
> > +
> >  	/* Make sure the D+ pullup pin is output */
> >  	WARN_ON(gpio_request(S3C2410_GPG(12), "udc pup"));
> >  	gpio_direction_output(S3C2410_GPG(12), 0);
> 
> This arch stuff should really be a separate patch too.

thank you for the review

cheers,
Domenico
