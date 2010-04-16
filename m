From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] mac8390: fix pr_info() calls and change return code
Date: Thu, 15 Apr 2010 21:34:14 -0700
Message-ID: <1271392454.2298.37.camel@Joe-Laptop.home>
References: <alpine.OSX.2.00.1004161214270.271@localhost>
	 <20100415.200113.215578006.davem@davemloft.net>
	 <alpine.OSX.2.00.1004161323340.271@localhost>
	 <alpine.OSX.2.00.1004161403160.271@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: Finn Thain <fthain@telegraphics.com.au>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.1004161403160.271@localhost>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-04-16 at 14:21 +1000, Finn Thain wrote:
> Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
> 
> --- a/drivers/net/mac8390.c	2010-04-16 13:31:04.000000000 +1000
> +++ b/drivers/net/mac8390.c	2010-04-16 14:02:29.000000000 +1000
> @@ -554,7 +554,7 @@
>  	case MAC8390_APPLE:
>  		switch (mac8390_testio(dev->mem_start)) {
>  		case ACCESS_UNKNOWN:
> -			pr_info("Don't know how to access card memory!\n");
> +			pr_err("Don't know how to access card memory!\n");
>  			return -ENODEV;
>  			break;
>  
> @@ -643,8 +643,8 @@
>  {
>  	__ei_open(dev);
>  	if (request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev)) {
> -		pr_info("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
> -		return -EAGAIN;
> +		pr_err("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
> +		return -EBUSY;

You should document the reason for the
return code change in the changelog.
Why is it better to use -EBUSY?

>  	}
>  	return 0;
>  }
> @@ -660,7 +660,7 @@
>  {
>  	ei_status.txing = 0;
>  	if (ei_debug > 1)
> -		pr_info("reset not supported\n");
> +		printk(KERN_DEBUG "reset not supported\n");

It'd be better to prefix this with the driver name
or use something like netdev_dbg with #define DEBUG
otherwise it's "huh? what device emits this message?"
when reading the logs.

Something like:
	printk(KERN_DEBUG pr_fmt("reset not supported\n"));
or
#define DEBUG
	netdev_dbg(dev, "reset not supported\n");
or
#define DEBUG
	pr_debug("reset not supported\n");

>  	if (ei_debug > 1)
> -		pr_cont("reset complete\n");
> +		printk(KERN_CONT "reset complete\n");

unnecessary conversion.
