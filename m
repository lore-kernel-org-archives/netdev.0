From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 4/5] drivers/net/can: Correct NULL test
Date: Mon, 28 Dec 2009 14:49:58 +0100
Message-ID: <4B38B786.9020609@hartkopp.net>
References: <Pine.LNX.4.64.0912272227290.20548@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, chri <chripell@gmail.com>,
	chripell@evolware.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:26106 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbZL1NuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 08:50:04 -0500
In-Reply-To: <Pine.LNX.4.64.0912272227290.20548@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>

Thanks Julia!

I added Christian Pellegrin who is the author of this driver in CC.

An obvious copy/paste error :-)

Regards,
Oliver

Acked-by: Oliver Hartkopp <oliver@hartkopp.net>

> 
> Test the just-allocated value for NULL rather than some other value.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression x,y;
> statement S;
> @@
> 
> x = \(kmalloc\|kcalloc\|kzalloc\)(...);
> (
> if ((x) == NULL) S
> |
> if (
> -   y
> +   x
>        == NULL)
>  S
> )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> ---
>  drivers/net/can/mcp251x.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -u -p a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
> --- a/drivers/net/can/mcp251x.c
> +++ b/drivers/net/can/mcp251x.c
> @@ -990,7 +990,7 @@ static int __devinit mcp251x_can_probe(s
>  			goto error_tx_buf;
>  		}
>  		priv->spi_rx_buf = kmalloc(SPI_TRANSFER_BUF_LEN, GFP_KERNEL);
> -		if (!priv->spi_tx_buf) {
> +		if (!priv->spi_rx_buf) {
>  			ret = -ENOMEM;
>  			goto error_rx_buf;
>  		}
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

