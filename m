From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH] bcm63xx_enet: timeout off by one in do_mdio_op()
Date: Wed, 30 Sep 2009 16:01:28 +0200
Message-ID: <1254319288.1627.758.camel@sakura.staff.proxad.net>
References: <4AB7DD50.6030409@gmail.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:43274 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299AbZI3OBd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2009 10:01:33 -0400
In-Reply-To: <4AB7DD50.6030409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2009-09-21 at 22:08 +0200, Roel Kluin wrote:

Hi Roel,

> `while (limit-- >= 0)' reaches -2 after the loop upon timeout.

The 1000us limit was chosen arbitrarily, since mdio access are much
shorter, and was just to prevent CPU lockup in case of hardware bug.

But it looks like a bug, and since you're the second one reporting this,
this should be fixed :)


> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Acked-by: Maxime Bizon <mbizon@freebox.fr>

> ---
> Small chance to occur, probably.
> 
> diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
> index 09d2709..ba29dc3 100644
> --- a/drivers/net/bcm63xx_enet.c
> +++ b/drivers/net/bcm63xx_enet.c
> @@ -90,7 +90,7 @@ static int do_mdio_op(struct bcm_enet_priv *priv, unsigned int data)
>  		if (enet_readl(priv, ENET_IR_REG) & ENET_IR_MII)
>  			break;
>  		udelay(1);
> -	} while (limit-- >= 0);
> +	} while (limit-- > 0);
>  
>  	return (limit < 0) ? 1 : 0;
>  }


-- 
Maxime


