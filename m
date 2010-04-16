From: Finn Thain <fthain@telegraphics.com.au>
Subject: another cleanup patch gone wrong
Date: Fri, 16 Apr 2010 12:34:24 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1004161214270.271@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <p_gortmaker@yahoo.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux/m68k <linux-m68k@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


...but this one was already merged, unfortunately.

> Use printk_once
> Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Convert printks without KERN_<level> to pr_info and pr_cont
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 
> diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
> index 517cee4..8bd09e2 100644 (file)
> --- a/drivers/net/mac8390.c
> +++ b/drivers/net/mac8390.c
> @@ -17,6 +17,8 @@
>  /* 2002-12-30: Try to support more cards, some clues from NetBSD driver */
>  /* 2003-12-26: Make sure Asante cards always work. */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +

Why the macro? You only used it once.

The pr_xxx naming convention belongs to a kernel-wide include file. Is it 
really a good idea to start repurposing it in .c files?

> @@ -545,7 +537,7 @@ static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * nd
>         case MAC8390_APPLE:
>                 switch (mac8390_testio(dev->mem_start)) {
>                 case ACCESS_UNKNOWN:
> -                       printk("Don't know how to access card memory!\n");
> +                       pr_info("Don't know how to access card memory!\n");

No, this is pr_err. The driver sets dev->mem_start expecting it to work, 
obviously.

>                         return -ENODEV;
>                         break;
>  

> @@ -633,7 +626,7 @@ static int mac8390_open(struct net_device *dev)
>  {
>         __ei_open(dev);
>         if (request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev)) {
> -               printk ("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
> +               pr_info("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
>                 return -EAGAIN;

Same here.

>         }
>         return 0;
> @@ -650,7 +643,7 @@ static void mac8390_no_reset(struct net_device *dev)
>  {
>         ei_status.txing = 0;
>         if (ei_debug > 1)
> -               printk("reset not supported\n");
> +               pr_info("reset not supported\n");

I think you meant pr_debug().

>         return;
>  }
>  
> @@ -658,11 +651,11 @@ static void interlan_reset(struct net_device *dev)
>  {
>         unsigned char *target=nubus_slot_addr(IRQ2SLOT(dev->irq));
>         if (ei_debug > 1)
> -               printk("Need to reset the NS8390 t=%lu...", jiffies);
> +               pr_info("Need to reset the NS8390 t=%lu...", jiffies);

Same here.

Finn
