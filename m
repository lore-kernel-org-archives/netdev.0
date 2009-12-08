From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive
 window.
Date: Tue, 08 Dec 2009 15:00:36 -0800
Message-ID: <1260313236.27677.163.camel@Joe-Laptop.home>
References: <pvm638hum1a.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1100 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966891AbZLHXAa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 18:00:30 -0500
In-Reply-To: <pvm638hum1a.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-12-08 at 14:40 -0800, chavey@google.com wrote:
> Add a sysctl, tcp_init_rcv_wnd, to set the TCP initial receive window
> size advertised by passive and active TCP connections. 
[]
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 2dcf04d..85232fc 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -656,6 +656,14 @@ static struct ctl_table ipv4_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec
>  	},
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "tcp_init_rcv_wnd",
> +		.data 		= &sysctl_tcp_init_rcv_wnd,
> +		.maxlen 	= sizeof(int),
> +		.mode 		= 0644,
> +		.proc_handler 	= &proc_dointvec,

		.proc_handler	= proc_dointvec_minmax,
		.extra1		= &zero,
		.extra2		= &SOMESTATIC_FOR_TCP_INIT_RCV_WND_MAX,

?


