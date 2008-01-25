From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] TCP:Fix a bug in strategy_allowed_congestion_control
Date: Fri, 25 Jan 2008 08:25:53 -0800
Message-ID: <20080125082553.78e1d207@deepthought>
References: <47998B55.1030305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Sam Jansen <sjansen@google.com>
To: shanwei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36596 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753311AbYAYQ0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 11:26:21 -0500
In-Reply-To: <47998B55.1030305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Jan 2008 15:10:13 +0800
shanwei <shanwei@cn.fujitsu.com> wrote:

> hi all:
> 
> In strategy_allowed_congestion_control of the 2.6.24 kernel, 
> when sysctl_string return 1 on success,it should call 
> tcp_set_allowed_congestion_control to set the allowed congestion
> control.But, it don't.
> the sysctl_string return 1 on success, otherwise return negative,
> never return 0.The patch fix the problem.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> 
> diff -Nuarp linux-2.6.24/net/ipv4/sysctl_net_ipv4.c linux-2.6.24-new/net/ipv4/sysctl_net_ipv4.c
> --- linux-2.6.24/net/ipv4/sysctl_net_ipv4.c	2008-01-25 06:58:37.000000000 +0800
> +++ linux-2.6.24-new/net/ipv4/sysctl_net_ipv4.c	2008-01-25 12:23:20.000000000 +0800
> @@ -248,7 +248,7 @@ static int strategy_allowed_congestion_c
>  
>  	tcp_get_available_congestion_control(tbl.data, tbl.maxlen);
>  	ret = sysctl_string(&tbl, name, nlen, oldval, oldlenp, newval, newlen);
> -	if (ret == 0 && newval && newlen)
> +	if (ret == 1 && newval && newlen)
>  		ret = tcp_set_allowed_congestion_control(tbl.data);
>  	kfree(tbl.data);
> 
> 

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

This parallels previous fix by Sam Jansen.
