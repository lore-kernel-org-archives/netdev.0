From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v5 2/7] ipv6 addrconf: remove addrconf_sysctl_hop_limit()
Date: Tue, 27 Sep 2016 19:18:22 +0900
Message-ID: <a669c581-2993-a269-db34-b8db269ed34f@miraclelinux.com>
References: <CANP3RGfHPZLHFnp4Rq8_dRNCro6Uh8O8767NgoGu7gvzu5h9BQ@mail.gmail.com>
 <1474969963-17402-1-git-send-email-zenczykowski@gmail.com>
 <1474969963-17402-3-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36850 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751469AbcI0KS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 06:18:26 -0400
Received: by mail-pa0-f53.google.com with SMTP id qn7so4278107pac.3
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 03:18:26 -0700 (PDT)
In-Reply-To: <1474969963-17402-3-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Maciej Żenczykowski wrote:
> From: Maciej Żenczykowski <maze@google.com>
> 
> replace with extra1/2 magic
> 
> Signed-off-by: Maciej Żenczykowski <maze@google.com>
> ---
>  net/ipv6/addrconf.c | 21 ++++++---------------
>  1 file changed, 6 insertions(+), 15 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 11fa1a5564d4..8bd2d06eefe7 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -5467,20 +5467,6 @@ int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
>  }
>  
>  static
> -int addrconf_sysctl_hop_limit(struct ctl_table *ctl, int write,
> -                              void __user *buffer, size_t *lenp, loff_t *ppos)
> -{
> -	struct ctl_table lctl;
> -	int min_hl = 1, max_hl = 255;
> -
> -	lctl = *ctl;
> -	lctl.extra1 = &min_hl;
> -	lctl.extra2 = &max_hl;
> -
> -	return proc_dointvec_minmax(&lctl, write, buffer, lenp, ppos);
> -}
> -
> -static
>  int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
>  			void __user *buffer, size_t *lenp, loff_t *ppos)
>  {
> @@ -5713,6 +5699,9 @@ int addrconf_sysctl_ignore_routes_with_linkdown(struct ctl_table *ctl,
>  	return ret;
>  }
>  
> +static const int one = 1;
> +static const int two_five_five = 255;
> +
>  static const struct ctl_table addrconf_sysctl[] = {
>  	{
>  		.procname	= "forwarding",
> @@ -5726,7 +5715,9 @@ static const struct ctl_table addrconf_sysctl[] = {
>  		.data		= &ipv6_devconf.hop_limit,
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
> -		.proc_handler	= addrconf_sysctl_hop_limit,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= (void *)&one,
> +		.extra2		= (void *)&two_five_five,
>  	},
>  	{
>  		.procname	= "mtu",
> 

Please submit this in a different series of patches
(like 1/7).

--yoshfuji
