From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 26/43] drivers/net/sfc: fix sparse warning: symbol shadows an earlier one
Date: Mon, 16 Feb 2009 00:38:20 +0000
Message-ID: <20090216003820.GO15266@solarflare.com>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net> <20090214213932.24377.94262.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:46586 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753550AbZBPAiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 19:38:22 -0500
Content-Disposition: inline
In-Reply-To: <20090214213932.24377.94262.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Eder wrote:
> Impact: Move variable declaration as close to their usage as possible.
> 
> Fix this sparse warning:
>   drivers/net/sfc/tenxpress.c:589:22: warning: symbol 'link_ok' shadows an earlier one
>   drivers/net/sfc/tenxpress.c:575:30: originally declared here
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/tenxpress.c |    7 +++----
>  1 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
> index ac9eeab..5b0f451 100644
> --- a/drivers/net/sfc/tenxpress.c
> +++ b/drivers/net/sfc/tenxpress.c
> @@ -572,15 +572,14 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
>  static void tenxpress_phy_poll(struct efx_nic *efx)
>  {
>  	struct tenxpress_phy_data *phy_data = efx->phy_data;
> -	bool change = false, link_ok;
> -	unsigned link_fc;
> +	bool change = false;
>  
>  	if (efx->phy_type == PHY_TYPE_SFX7101) {
> -		link_ok = sfx7101_link_ok(efx);
> +		bool link_ok = sfx7101_link_ok(efx);
>  		if (link_ok != efx->link_up) {
>  			change = true;
>  		} else {
> -			link_fc = mdio_clause45_get_pause(efx);
> +			unsigned int link_fc = mdio_clause45_get_pause(efx);
>  			if (link_fc != efx->link_fc)
>  				change = true;
>  		}
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
