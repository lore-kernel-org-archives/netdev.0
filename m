From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 16/43] drivers/net/cxgb3: fix sparse warning: symbol shadows
 an earlier one
Date: Sun, 15 Feb 2009 15:14:09 +0100
Message-ID: <49982331.4050001@bfs.de>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net> <20090214211557.23489.75670.stgit@vmbox.hanneseder.net>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.sz.bfs.de ([194.94.69.70]:59315 "EHLO mx.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753646AbZBOOO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Feb 2009 09:14:26 -0500
In-Reply-To: <20090214211557.23489.75670.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hannes Eder schrieb:
> Impact: Move variable declaration as close to usage as possible.
> 
> Fix this sparse warning:
>   drivers/net/cxgb3/cxgb3_main.c:1586:21: warning: symbol 'cap' shadows an earlier one
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> ---
>  drivers/net/cxgb3/cxgb3_main.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
> index f2c7cc3..0f6062a 100644
> --- a/drivers/net/cxgb3/cxgb3_main.c
> +++ b/drivers/net/cxgb3/cxgb3_main.c
> @@ -1565,7 +1565,6 @@ static int speed_duplex_to_caps(int speed, int duplex)
>  
>  static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  {
> -	int cap;
>  	struct port_info *p = netdev_priv(dev);
>  	struct link_config *lc = &p->link_config;
>  
> @@ -1575,7 +1574,7 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  		 * being requested.
>  		 */
>  		if (cmd->autoneg == AUTONEG_DISABLE) {
> -			cap = speed_duplex_to_caps(cmd->speed, cmd->duplex);
> +			int cap = speed_duplex_to_caps(cmd->speed, cmd->duplex);
>  			if (lc->supported & cap)
>  				return 0;
>  		}
> 

Hello Hannes,
it seems that "cap" can be dropped completely.

if (lc->supported & speed_duplex_to_caps(cmd->speed, cmd->duplex) )
	return 0;


re,
 wh
