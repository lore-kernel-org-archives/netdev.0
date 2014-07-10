From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] net: cpmac: fix in debug messages
Date: Thu, 10 Jul 2014 10:04:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726FC65@AcuExch.aculab.com>
References: <1404986378-28555-1-git-send-email-varkabhadram@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"linux@rainbow-software.org" <linux@rainbow-software.org>,
	"balbi@ti.com" <balbi@ti.com>,
	"george.cherian@ti.com" <george.cherian@ti.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Varka Bhadram <varkab@cdac.in>
To: "'varkabhadram@gmail.com'" <varkabhadram@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46020 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751517AbaGJKGE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 06:06:04 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00914-08 for <netdev@vger.kernel.org>;
 Thu, 10 Jul 2014 11:05:54 +0100 (BST)
In-Reply-To: <1404986378-28555-1-git-send-email-varkabhadram@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: varkabhadram@gmail.com
> This patch fix the debug message format. This patch changes to the
> commit f160a2d0b524eeebd97a68e2fbb59fad4cdd3fee: net: cpmac: dynamic debug fixes
> 
> When we use pr_debug()/netdev_dbg() new lines are inserting in b/w
> the values. The format when i use the printk()
> 
> These formats used in skb dump and reg dump. This functions
> called from the entire code. So this will be enabled all the lines.

Actually it is much better to use a single print for each line.
Otherwise the output can get interleaved.
This might need a temporary buffer.

	David

> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>  drivers/net/ethernet/ti/cpmac.c |   24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
> index b68c5b5..3809f4e 100644
> --- a/drivers/net/ethernet/ti/cpmac.c
> +++ b/drivers/net/ethernet/ti/cpmac.c
> @@ -228,22 +228,22 @@ static void cpmac_dump_regs(struct net_device *dev)
>  	for (i = 0; i < CPMAC_REG_END; i += 4) {
>  		if (i % 16 == 0) {
>  			if (i)
> -				pr_cont("\n");
> -			netdev_dbg(dev, "reg[%p]:", priv->regs + i);
> +				printk("\n");
> +			printk("%s: reg[%p]:", dev->name, priv->regs + i);
>  		}
> -		pr_debug(" %08x", cpmac_read(priv->regs, i));
> +		printk(" %08x", cpmac_read(priv->regs, i));
>  	}
> -	pr_debug("\n");
> +	printk("\n");
>  }
> 
>  static void cpmac_dump_desc(struct net_device *dev, struct cpmac_desc *desc)
>  {
>  	int i;
> 
> -	netdev_dbg(dev, "desc[%p]:", desc);
> +	printk("%s: desc[%p]:", dev->name, desc);
>  	for (i = 0; i < sizeof(*desc) / 4; i++)
> -		pr_debug(" %08x", ((u32 *)desc)[i]);
> -	pr_debug("\n");
> +		printk(" %08x", ((u32 *)desc)[i]);
> +	printk("\n");
>  }
> 
>  static void cpmac_dump_all_desc(struct net_device *dev)
> @@ -261,16 +261,16 @@ static void cpmac_dump_skb(struct net_device *dev, struct sk_buff *skb)
>  {
>  	int i;
> 
> -	netdev_dbg(dev, "skb 0x%p, len=%d\n", skb, skb->len);
> +	printk("%s: skb 0x%p, len=%d\n", dev->name, skb, skb->len);
>  	for (i = 0; i < skb->len; i++) {
>  		if (i % 16 == 0) {
>  			if (i)
> -				pr_cont("\n");
> -			netdev_dbg(dev, "data[%p]:", skb->data + i);
> +				printk("\n");
> +			printk("%s: data[%p]:", dev->name, skb->data + i);
>  		}
> -		pr_debug(" %02x", ((u8 *)skb->data)[i]);
> +		printk(" %02x", ((u8 *)skb->data)[i]);
>  	}
> -	pr_debug("\n");
> +	printk("\n");
>  }
> 
>  static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
> --
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
