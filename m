From: walter harms <wharms@bfs.de>
Subject: Re: [patch -next v2] mv643xx_eth: potential null dereference
Date: Fri, 23 Jul 2010 18:30:22 +0200
Message-ID: <4C49C39E.8020502@bfs.de>
References: <20100723101528.GF26313@bicker> <1279881177.24768.1623.camel@Joe-Laptop.home> <20100723110504.GG26313@bicker>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Denis Kirjanov <kirjanov@gmail.com>,
	Saeed Bishara <saeed@marvell.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:62253 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757467Ab0GWQaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 12:30:25 -0400
In-Reply-To: <20100723110504.GG26313@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Carpenter schrieb:
> We assume that "pd" can be null on the previous line, and throughout the
> function so we should check it here as well.  This was introduced by
> 9b2c2ff7a1c0 "mv643xx_eth: use sw csum for big packets"
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> v2: style change
> 
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index 73bb8ea..f5e72fe 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -2670,7 +2670,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
>  	 * Detect hardware parameters.
>  	 */
>  	msp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
> -	msp->tx_csum_limit = pd->tx_csum_limit ? pd->tx_csum_limit : 9 * 1024;
> +	msp->tx_csum_limit = (pd != NULL && pd->tx_csum_limit) ?
> +					pd->tx_csum_limit : 9 * 1024;
>  	infer_hw_params(msp);
>  
>  	platform_set_drvdata(pdev, msp);

this is a bit complicated, IMHO ppl have a bigger chance to discover what is going on
with this version:

    if (!pd ) {
       msp->t_clk = 133000000;
       msp->tx_csum_limit = 9 * 1024;
     }
     else
      {
	msp->t_clk = pd->t_clk ? pd->t_clk : 133000000 ;
        msp->tx_csum_limit = pd->tx_csum_limit ? pd->tx_csum_limit : 9 * 1024;
       }


re,
 wh







