From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive window.
Date: Sat, 12 Dec 2009 19:27:49 -0800
Message-ID: <m1pr6jmu2y.fsf@fess.ebiederm.org>
References: <pvmfx7jbn2h.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com,
	joe@perches.com, eric.dumazet@gmail.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36185 "HELO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757596AbZLMD15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 22:27:57 -0500
In-Reply-To: <pvmfx7jbn2h.fsf@chavey.mtv.corp.google.com> (chavey@google.com's message of "Wed\, 09 Dec 2009 18\:05\:42 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

chavey@google.com writes:
>  
>  /* Update system visible IP port range */
>  static void set_local_port_range(int range[2])
> @@ -656,6 +658,16 @@ static struct ctl_table ipv4_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec
>  	},
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "tcp_init_rcv_wnd",
> +		.data 		= &sysctl_tcp_init_rcv_wnd,
> +		.maxlen 	= sizeof(int),
> +		.mode 		= 0644,
> +		.proc_handler 	= proc_dointvec_minmax,
> +		.extra1		= &zero,
> +		.extra2		= &tcp_init_rcv_wnd_max
> +	},
>  #ifdef CONFIG_NETLABEL
>  	{
>  		.ctl_name	= NET_CIPSOV4_CACHE_ENABLE,

It looks like this won't be solved with a sysctl now, but I want to
mention that ctl_name is now gone.  So this patch won't compile in
mainline any more.

Eric
