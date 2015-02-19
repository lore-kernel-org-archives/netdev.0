From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH next] bonding: simple code refactor
Date: Thu, 19 Feb 2015 13:39:05 -0500
Message-ID: <20150219183905.GH580@gospo.home.greyhouse.net>
References: <1424369605-26655-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:64647 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbBSSjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 13:39:10 -0500
Received: by mail-qg0-f43.google.com with SMTP id i50so8444043qgf.2
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 10:39:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1424369605-26655-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 10:13:25AM -0800, Mahesh Bandewar wrote:
> Remove duplicate code.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Looks good.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
>  drivers/net/bonding/bond_main.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 19b12fbd808d..cbf77d388f53 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2933,6 +2933,8 @@ static int bond_slave_netdev_event(unsigned long event,
>  			if (old_duplex != slave->duplex)
>  				bond_3ad_adapter_duplex_changed(slave);
>  		}
> +		/* Fallthrough */
> +	case NETDEV_DOWN:
>  		/* Refresh slave-array if applicable!
>  		 * If the setup does not use miimon or arpmon (mode-specific!),
>  		 * then these events will not cause the slave-array to be
> @@ -2944,10 +2946,6 @@ static int bond_slave_netdev_event(unsigned long event,
>  		if (bond_mode_uses_xmit_hash(bond))
>  			bond_update_slave_arr(bond, NULL);
>  		break;
> -	case NETDEV_DOWN:
> -		if (bond_mode_uses_xmit_hash(bond))
> -			bond_update_slave_arr(bond, NULL);
> -		break;
>  	case NETDEV_CHANGEMTU:
>  		/* TODO: Should slaves be allowed to
>  		 * independently alter their MTU?  For
> -- 
> 2.2.0.rc0.207.ga3a616c
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
