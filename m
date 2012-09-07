From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4/route: arg delay is useless in
 rt_cache_flush()
Date: Fri, 07 Sep 2012 12:29:54 +0200
Message-ID: <1347013794.2484.488.camel@edumazet-glaptop>
References: <1347010284-3419-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61341 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753726Ab2IGK37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 06:29:59 -0400
Received: by bkwj10 with SMTP id j10so1289660bkw.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 03:29:58 -0700 (PDT)
In-Reply-To: <1347010284-3419-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-07 at 11:31 +0200, Nicolas Dichtel wrote:
> Since route cache deletion (89aef8921bfbac22f), delay is no
> more used. Remove it.
> 
...

>  #ifdef CONFIG_SYSCTL
> @@ -2354,16 +2350,12 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
>  					size_t *lenp, loff_t *ppos)
>  {
>  	if (write) {
> -		int flush_delay;
>  		ctl_table ctl;
>  		struct net *net;
>  
>  		memcpy(&ctl, __ctl, sizeof(ctl));
> -		ctl.data = &flush_delay;
> -		proc_dointvec(&ctl, write, buffer, lenp, ppos);
> -
>  		net = (struct net *)__ctl->extra1;
> -		rt_cache_flush(net, flush_delay);
> +		rt_cache_flush(net);
>  		return 0;
>  	}
>  

Why do you keep ctl then ?

	if (write) {
		rt_cache_flush((struct net *)__ctl->extra1);
		return 0;
	}
