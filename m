From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 2.6.17-rc1] Fix RtNetlink ENCODE security permissions
Date: Fri, 14 Apr 2006 10:59:13 -0700
Message-ID: <20060414105913.0222a8a6.rdunlap@xenotime.net>
References: <20060414174726.GA24421@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:14316 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751351AbWDNR4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 13:56:48 -0400
Received: from midway.site ([71.111.157.99]) by xenotime.net for <netdev@vger.kernel.org>; Fri, 14 Apr 2006 10:56:45 -0700
To: jt@hpl.hp.com
In-Reply-To: <20060414174726.GA24421@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Apr 2006 10:47:26 -0700 Jean Tourrilhes wrote:

> 	Hi John,
> 
> 	I've just realised that the RtNetlink code does not check the
> permission for SIOCGIWENCODE and SIOCGIWENCODEEXT, which means that
> any user can read the encryption keys. The fix is trivial and should
> go in 2.6.17 alonside the two other patch I sent you last week.
> 	Fully tested on 2.6.17-rc1.

and for -stable ??

> 	Have fun...
> 
> 	Jean
> 
> Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>
> 
> -----------------------------------------------------------
> 
> diff -u -p linux/net/core/wireless.j1.c linux/net/core/wireless.c
> --- linux/net/core/wireless.j1.c	2006-04-13 18:29:49.000000000 -0700
> +++ linux/net/core/wireless.c	2006-04-13 18:35:59.000000000 -0700
> @@ -1726,6 +1726,14 @@ int wireless_rtnetlink_get(struct net_de
>  	if(!IW_IS_GET(request->cmd))
>  		return -EOPNOTSUPP;
>  
> +	/* If command is `get the encoding parameters', check if
> +	 * the user has the right to do it */
> +	if (request->cmd == SIOCGIWENCODE ||
> +	    request->cmd == SIOCGIWENCODEEXT) {
> +		if (!capable(CAP_NET_ADMIN))
> +			return -EPERM;
> +	}
> +
>  	/* Special cases */
>  	if(request->cmd == SIOCGIWSTATS)
>  		/* Get Wireless Stats */
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


---
~Randy
