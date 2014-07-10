From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net v2 3/7] net: cpmac: dynamic debug fixes
Date: Thu, 10 Jul 2014 01:31:49 -0700
Message-ID: <1404981109.8839.6.camel@joe-AO725>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
	 <1404970545-26508-4-git-send-email-varkabhadram@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	linux@rainbow-software.org, balbi@ti.com, george.cherian@ti.com,
	davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0229.hostedemail.com ([216.40.44.229]:60641 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752124AbaGJIbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:31:52 -0400
In-Reply-To: <1404970545-26508-4-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-10 at 11:05 +0530, varkabhadram@gmail.com wrote:
> From: Varka Bhadram <varkab@cdac.in>
> 
> This patch does the following changes
> 1. convert printk(KERN_DEBUG.. to netdev_dbg() if we have net_device object
>    or convert to dev_dbg() if we have device object.
[]
> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
[]
> @@ -228,21 +228,20 @@ static void cpmac_dump_regs(struct net_device *dev)
>  		if (i % 16 == 0) {
>  			if (i)
>  				pr_cont("\n");
> -			printk(KERN_DEBUG "%s: reg[%p]:", dev->name,
> -			       priv->regs + i);
> +			netdev_dbg(dev, "reg[%p]:", priv->regs + i);
>  		}
> -		printk(" %08x", cpmac_read(priv->regs, i));
> +		pr_debug(" %08x", cpmac_read(priv->regs, i));
>  	}
> -	printk("\n");
> +	pr_debug("\n");
>  }

This changes output from a compact form to
usig very many individual lines like:

<7>dev->name: reg[addr]: p1 p2 p3 p4 p5 p6 p7 p8
<7>dev->name: reg[addr]: p9 pa ...            pn

to:

<7>bus desc/dev->name: reg[addr]:
<7> p1
<7> p2
...
<7>bus desc/dev->name: reg[addr]:
<7> p9
<7> pa
...
<7> pn
