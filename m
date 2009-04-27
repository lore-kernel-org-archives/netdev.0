From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] gianfar: irq_of_parse_and_map() error unnoticed
Date: Mon, 27 Apr 2009 12:23:16 -0700
Message-ID: <20090427122316.1a8fec91.akpm@linux-foundation.org>
References: <49F0649C.8030908@gmail.com>
	<20090427.031116.43598009.davem@davemloft.net>
	<49F5917A.3060909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35684 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753563AbZD0TZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 15:25:06 -0400
In-Reply-To: <49F5917A.3060909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Apr 2009 13:05:30 +0200
Roel Kluin <roel.kluin@gmail.com> wrote:

> priv->interruptTransmit, -Receive and -Error are unsigned, so the error path
> wasn't taken when irq_of_parse_and_map() returned an incorrect irq.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com> 
> ---
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index b2c4967..55c2ce8 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -203,9 +203,9 @@ static int gfar_of_init(struct net_device *dev)
>  
>  		priv->interruptError = irq_of_parse_and_map(np, 2);
>  
> -		if (priv->interruptTransmit < 0 ||
> -				priv->interruptReceive < 0 ||
> -				priv->interruptError < 0) {
> +		if (priv->interruptTransmit == NO_IRQ ||
> +				priv->interruptReceive == NO_IRQ ||
> +				priv->interruptError == NO_IRQ) {
>  			err = -EINVAL;
>  			goto err_out;
>  		}

I guess that's OK, as gianfar.c appears to be a ppc-only thing, and ppc
does implement NO_IRQ.

However what a lot (all) rtc drivers do is

	if (irq <= 0)

which (afaik) will dtrt in all cases: NO_IRQ==0, NO_IRQ<0,
!defined(NO_IRQ).

Then again, it will dtwt if the platform allows irq numbers of zero.

argh, how did we get into this pickle?
