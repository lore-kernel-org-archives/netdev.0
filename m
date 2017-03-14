From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next] bonding: add 802.3ad support for 25G speeds
Date: Tue, 14 Mar 2017 14:17:09 -0400
Message-ID: <20170314181709.GA32819@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170314154832.13719-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32800 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdCNSRU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 14:17:20 -0400
Received: by mail-wm0-f66.google.com with SMTP id n11so1134655wma.0
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 11:17:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170314154832.13719-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 11:48:32AM -0400, Jarod Wilson wrote:
> Cut-n-paste enablement of 802.3ad bonding on 25G NICs, which currently
> report 0 as their bandwidth.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Look good, Jarod.  Probably time for a 50Gbps option, too....

Acked-by: Andy Gospodarek <andy@greyhouse.net>

> ---
> note: I swear I saw a patch for this already, but I don't see it on the
> list and it isn't committed, so here's this...
> 
>  drivers/net/bonding/bond_3ad.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 431926bba9f4..508713b4e533 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -92,6 +92,7 @@ enum ad_link_speed_type {
>  	AD_LINK_SPEED_2500MBPS,
>  	AD_LINK_SPEED_10000MBPS,
>  	AD_LINK_SPEED_20000MBPS,
> +	AD_LINK_SPEED_25000MBPS,
>  	AD_LINK_SPEED_40000MBPS,
>  	AD_LINK_SPEED_56000MBPS,
>  	AD_LINK_SPEED_100000MBPS,
> @@ -260,6 +261,7 @@ static inline int __check_agg_selection_timer(struct port *port)
>   *     %AD_LINK_SPEED_2500MBPS,
>   *     %AD_LINK_SPEED_10000MBPS
>   *     %AD_LINK_SPEED_20000MBPS
> + *     %AD_LINK_SPEED_25000MBPS
>   *     %AD_LINK_SPEED_40000MBPS
>   *     %AD_LINK_SPEED_56000MBPS
>   *     %AD_LINK_SPEED_100000MBPS
> @@ -302,6 +304,10 @@ static u16 __get_link_speed(struct port *port)
>  			speed = AD_LINK_SPEED_20000MBPS;
>  			break;
>  
> +		case SPEED_25000:
> +			speed = AD_LINK_SPEED_25000MBPS;
> +			break;
> +
>  		case SPEED_40000:
>  			speed = AD_LINK_SPEED_40000MBPS;
>  			break;
> @@ -707,6 +713,9 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
>  		case AD_LINK_SPEED_20000MBPS:
>  			bandwidth = nports * 20000;
>  			break;
> +		case AD_LINK_SPEED_25000MBPS:
> +			bandwidth = nports * 25000;
> +			break;
>  		case AD_LINK_SPEED_40000MBPS:
>  			bandwidth = nports * 40000;
>  			break;
> -- 
> 2.11.0
> 
