From: Joe Perches <joe@perches.com>
Subject: Re: [patch -next] mv643xx_eth: potential null dereference
Date: Fri, 23 Jul 2010 03:32:57 -0700
Message-ID: <1279881177.24768.1623.camel@Joe-Laptop.home>
References: <20100723101528.GF26313@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Saeed Bishara <saeed@marvell.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2064 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754489Ab0GWKc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 06:32:59 -0400
In-Reply-To: <20100723101528.GF26313@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-07-23 at 12:15 +0200, Dan Carpenter wrote:
> We assume that "pd" can be null on the previous line, and throughout the
> function so we should check it here as well.  This was introduced by
> 9b2c2ff7a1c0 "mv643xx_eth: use sw csum for big packets"
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index 2fcdb1e..9166f55 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -2675,7 +2675,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
>  	 * Detect hardware parameters.
>  	 */
>  	msp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
> -	msp->tx_csum_limit = pd->tx_csum_limit ? pd->tx_csum_limit : 9 * 1024;
> +	msp->tx_csum_limit = (pd && pd->tx_csum_limit) ?
> +					pd->tx_csum_limit : 9 * 1024;

It's odd using two different check styles for the same
test on consecutive lines.

How about using the same style:

	msp->tx_csum_limit = (pd != NULL && pd->tx_csum_limit) ?
					pd->tx_csum_limit : 9 * 1024;


