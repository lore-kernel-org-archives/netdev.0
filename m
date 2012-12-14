From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: sja1000: fix compilation on x86
Date: Fri, 14 Dec 2012 16:37:58 -0500 (EST)
Message-ID: <20121214.163758.465958297963655994.davem@davemloft.net>
References: <1355520824-23175-1-git-send-email-mkl@pengutronix.de>
	<1355520824-23175-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	sfr@canb.auug.org.au, andreas@gaisler.com
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1355520824-23175-2-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 14 Dec 2012 22:33:44 +0100

> @@ -121,7 +121,7 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
>  	}
>  
>  	irq = irq_of_parse_and_map(np, 0);
> -	if (irq == NO_IRQ) {
> +	if (irq <= 0) {
>  		dev_err(&ofdev->dev, "no irq found\n");
>  		err = -ENODEV;
>  		goto exit_unmap_mem;

I don't see anything existing which says this is the proper
transformation.

There is no consistency at all for the tests of the return
value of irq_of_parse_and_map().

And if anything testing against zero is the correct thing to
do, universally.

I'm not applying this or pulling from your tree, sorry.
