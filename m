From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH v6 3/7 RFC] TCPCT part 1c:
 sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS
Date: Fri, 13 Nov 2009 10:37:22 -0800
Message-ID: <1258137443.16857.124.camel@Joe-Laptop.home>
References: <4AFCDA9E.8050003@gmail.com>  <4AFCE13B.4060006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1042 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755973AbZKMShR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 13:37:17 -0500
In-Reply-To: <4AFCE13B.4060006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-11-12 at 23:31 -0500, William Allen Simpson wrote:
> Define sysctl (tcp_cookie_size) to turn on and off the cookie option
> default globally, instead of a compiled configuration option.
[]

> +#define TCP_COOKIE_MIN		 8		/*  64-bits */
> +#define TCP_COOKIE_MAX		16		/* 128-bits */

perhaps something like:

static const int TCP_COOKIE_MIN = 8;
static const int TCP_COOKIE_MAX = 16;

[]

> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -714,6 +714,14 @@ static struct ctl_table ipv4_table[] = {
>  	},
>  	{
>  		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "tcp_cookie_size",
> +		.data		= &sysctl_tcp_cookie_size,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec

with proc_dointvec_minmax

		.extra1		= &TCP_COOKIE_MIN,
		.extra2		= &TCP_COOKIE_MAX,

or even adding proc_dointvec_minmax_even
might save some cycles during cookie handling.


