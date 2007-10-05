From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC/PATCH 4/4] UDP memory usage accounting (take 4): memory
 limitation
Date: Fri, 5 Oct 2007 08:52:57 -0700
Message-ID: <20071005085257.24b2e5cc@freepuppy.rosehill>
References: <47065139.5030402@hitachi.com>
	<47065217.5050004@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>, ?? ?? <yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	"??@RedHat" <haoki@redhat.com>
To: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51135 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755316AbXJEPyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 11:54:43 -0400
In-Reply-To: <47065217.5050004@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 06 Oct 2007 00:02:47 +0900
Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com> wrote:

> This patch introduces memory limitation for UDP.
> 
> 
> signed-off-by: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
> signed-off-by: Hideo Aoki <haoki@redhat.com>

> Index: 2.6.23-rc9-udp_limit/net/ipv4/sysctl_net_ipv4.c
> ===================================================================
> --- 2.6.23-rc9-udp_limit.orig/net/ipv4/sysctl_net_ipv4.c
> +++ 2.6.23-rc9-udp_limit/net/ipv4/sysctl_net_ipv4.c
> @@ -17,6 +17,7 @@
>  #include <net/ip.h>
>  #include <net/route.h>
>  #include <net/tcp.h>
> +#include <net/udp.h>
>  #include <net/cipso_ipv4.h>
>  
>  /* From af_inet.c */
> @@ -599,6 +600,14 @@ ctl_table ipv4_table[] = {
>  		.proc_handler	= &proc_dointvec
>  	},
>  	{
> +		.ctl_name	= NET_UDP_MEM,
> +		.procname	= "udp_mem",
> +		.data		= &sysctl_udp_mem,
> +		.maxlen		= sizeof(sysctl_udp_mem),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec
> +	},
> +	{
>  		.ctl_name	= NET_TCP_APP_WIN,
>  		.procname	= "tcp_app_win",
>  		.data		= &sysctl_tcp_app_win,

if you use &proc_dointvec_minmax, then you could inforce min/max
values for udp_mem for the sysctl
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
