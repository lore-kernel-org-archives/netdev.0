From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net 2/3] bonding: fix 802.3ad support for 14G speed
Date: Thu, 8 Jun 2017 08:55:19 -0400
Message-ID: <20170608125519.GB78114@C02RW35GFVH8.dhcp.broadcom.net>
References: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
 <1496913493-23293-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, thibaut.collet@6wind.com, linville@tuxdriver.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34634 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751481AbdFHMzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 08:55:21 -0400
Received: by mail-qt0-f194.google.com with SMTP id o21so7862187qtb.1
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 05:55:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1496913493-23293-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 08, 2017 at 11:18:12AM +0200, Nicolas Dichtel wrote:
> This patch adds 14 Gbps enum definition, and fixes
> aggregated bandwidth calculation based on above slave links.
> 
> Fixes: 0d7e2d2166f6 ("IB/ipoib: add get_link_ksettings in ethtool")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Andy Gospodarek <andy@greyhouse.net>

> ---
>  drivers/net/bonding/bond_3ad.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index d1b09be63ba4..e5386ab706ec 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -92,6 +92,7 @@ enum ad_link_speed_type {
>  	AD_LINK_SPEED_2500MBPS,
>  	AD_LINK_SPEED_5000MBPS,
>  	AD_LINK_SPEED_10000MBPS,
> +	AD_LINK_SPEED_14000MBPS,
>  	AD_LINK_SPEED_20000MBPS,
>  	AD_LINK_SPEED_25000MBPS,
>  	AD_LINK_SPEED_40000MBPS,
> @@ -263,6 +264,7 @@ static inline int __check_agg_selection_timer(struct port *port)
>   *     %AD_LINK_SPEED_2500MBPS,
>   *     %AD_LINK_SPEED_5000MBPS,
>   *     %AD_LINK_SPEED_10000MBPS
> + *     %AD_LINK_SPEED_14000MBPS,
>   *     %AD_LINK_SPEED_20000MBPS
>   *     %AD_LINK_SPEED_25000MBPS
>   *     %AD_LINK_SPEED_40000MBPS
> @@ -308,6 +310,10 @@ static u16 __get_link_speed(struct port *port)
>  			speed = AD_LINK_SPEED_10000MBPS;
>  			break;
>  
> +		case SPEED_14000:
> +			speed = AD_LINK_SPEED_14000MBPS;
> +			break;
> +
>  		case SPEED_20000:
>  			speed = AD_LINK_SPEED_20000MBPS;
>  			break;
> @@ -725,6 +731,9 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
>  		case AD_LINK_SPEED_10000MBPS:
>  			bandwidth = nports * 10000;
>  			break;
> +		case AD_LINK_SPEED_14000MBPS:
> +			bandwidth = nports * 14000;
> +			break;
>  		case AD_LINK_SPEED_20000MBPS:
>  			bandwidth = nports * 20000;
>  			break;
> -- 
> 2.8.1
> 
