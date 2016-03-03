From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: renesas: sh_eth: don't open code
 of_device_get_match_data()
Date: Thu, 03 Mar 2016 16:39:30 -0500 (EST)
Message-ID: <20160303.163930.200378115614137289.davem@davemloft.net>
References: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
	<1456850284-8336-2-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-renesas-soc@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: wsa@the-dreams.de
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456850284-8336-2-git-send-email-wsa@the-dreams.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfram Sang <wsa@the-dreams.de>
Date: Tue,  1 Mar 2016 17:37:59 +0100

> From: Wolfram Sang <wsa+renesas@sang-engineering.com>
> 
> This change will also make Coverity happy by avoiding a theoretical NULL
> pointer dereference; yet another reason is to use the above helper function
> to tighten the code and make it more readable.
> 
> Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
> ---
> 
> Tested on a Lager board.
> 
>  drivers/net/ethernet/renesas/sh_eth.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 0a150b2289146f..8b6c07fe3d407d 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -3056,15 +3056,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>  	mdp->ether_link_active_low = pd->ether_link_active_low;
>  
>  	/* set cpu data */
> -	if (id) {
> +	if (id)
>  		mdp->cd = (struct sh_eth_cpu_data *)id->driver_data;
> -	} else	{
> -		const struct of_device_id *match;
> +	else
> +		mdp->cd = (struct sh_eth_cpu_data *)of_device_get_match_data(&pdev->dev);

Applied, although mdp->cd should probably be made const.  It is not legal to make
modifications to the objects returned from this interface.
