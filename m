From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ethtool: fix sparse warning
Date: Mon, 11 Feb 2013 17:21:59 +0000
Message-ID: <1360603319.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130211082228.1f1d7f88@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33074 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757838Ab3BKRWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 12:22:21 -0500
In-Reply-To: <20130211082228.1f1d7f88@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-11 at 08:22 -0800, Stephen Hemminger wrote:
> Fixes sparse complaints about dropping __user in casts.
>  warning: cast removes address space of expression
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

> 
> --- a/net/socket.c	2013-02-11 08:17:45.081011548 -0800
> +++ b/net/socket.c	2013-02-11 08:19:52.743355382 -0800
> @@ -2837,7 +2837,7 @@ static int ethtool_ioctl(struct net *net
>  	}
>  
>  	ifr = compat_alloc_user_space(buf_size);
> -	rxnfc = (void *)ifr + ALIGN(sizeof(struct ifreq), 8);
> +	rxnfc = (void __user *)ifr + ALIGN(sizeof(struct ifreq), 8);
>  
>  	if (copy_in_user(&ifr->ifr_name, &ifr32->ifr_name, IFNAMSIZ))
>  		return -EFAULT;
> @@ -2861,12 +2861,12 @@ static int ethtool_ioctl(struct net *net
>  			offsetof(struct ethtool_rxnfc, fs.ring_cookie));
>  
>  		if (copy_in_user(rxnfc, compat_rxnfc,
> -				 (void *)(&rxnfc->fs.m_ext + 1) -
> -				 (void *)rxnfc) ||
> +				 (void __user *)(&rxnfc->fs.m_ext + 1) -
> +				 (void __user *)rxnfc) ||
>  		    copy_in_user(&rxnfc->fs.ring_cookie,
>  				 &compat_rxnfc->fs.ring_cookie,
> -				 (void *)(&rxnfc->fs.location + 1) -
> -				 (void *)&rxnfc->fs.ring_cookie) ||
> +				 (void __user *)(&rxnfc->fs.location + 1) -
> +				 (void __user *)&rxnfc->fs.ring_cookie) ||
>  		    copy_in_user(&rxnfc->rule_cnt, &compat_rxnfc->rule_cnt,
>  				 sizeof(rxnfc->rule_cnt)))
>  			return -EFAULT;
> @@ -2878,12 +2878,12 @@ static int ethtool_ioctl(struct net *net
>  
>  	if (convert_out) {
>  		if (copy_in_user(compat_rxnfc, rxnfc,
> -				 (const void *)(&rxnfc->fs.m_ext + 1) -
> -				 (const void *)rxnfc) ||
> +				 (const void __user *)(&rxnfc->fs.m_ext + 1) -
> +				 (const void __user *)rxnfc) ||
>  		    copy_in_user(&compat_rxnfc->fs.ring_cookie,
>  				 &rxnfc->fs.ring_cookie,
> -				 (const void *)(&rxnfc->fs.location + 1) -
> -				 (const void *)&rxnfc->fs.ring_cookie) ||
> +				 (const void __user *)(&rxnfc->fs.location + 1) -
> +				 (const void __user *)&rxnfc->fs.ring_cookie) ||
>  		    copy_in_user(&compat_rxnfc->rule_cnt, &rxnfc->rule_cnt,
>  				 sizeof(rxnfc->rule_cnt)))
>  			return -EFAULT;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
