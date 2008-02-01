From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP:Fix a bug in strategy_allowed_congestion_control
Date: Thu, 31 Jan 2008 16:47:47 -0800 (PST)
Message-ID: <20080131.164747.243359072.davem@davemloft.net>
References: <47998B55.1030305@cn.fujitsu.com>
	<20080125082553.78e1d207@deepthought>
	<479D386F.5030805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	sjansen@google.com
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40856
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964863AbYBAAr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 19:47:26 -0500
In-Reply-To: <479D386F.5030805@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: shanwei <shanwei@cn.fujitsu.com>
Date: Mon, 28 Jan 2008 10:05:35 +0800

> Stephen Hemminger 写道:
> > On Fri, 25 Jan 2008 15:10:13 +0800
> > shanwei <shanwei@cn.fujitsu.com> wrote:
> > 
> >> hi all:
> >>
> >> In strategy_allowed_congestion_control of the 2.6.24 kernel, 
> >> when sysctl_string return 1 on success,it should call 
> >> tcp_set_allowed_congestion_control to set the allowed congestion
> >> control.But, it don't.
> >> the sysctl_string return 1 on success, otherwise return negative,
> >> never return 0.The patch fix the problem.
> >>
> >> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> >>
> >> diff -Nuarp linux-2.6.24/net/ipv4/sysctl_net_ipv4.c linux-2.6.24-new/net/ipv4/sysctl_net_ipv4.c
> >> --- linux-2.6.24/net/ipv4/sysctl_net_ipv4.c	2008-01-25 06:58:37.000000000 +0800
> >> +++ linux-2.6.24-new/net/ipv4/sysctl_net_ipv4.c	2008-01-25 12:23:20.000000000 +0800
> >> @@ -248,7 +248,7 @@ static int strategy_allowed_congestion_c
> >>  
> >>  	tcp_get_available_congestion_control(tbl.data, tbl.maxlen);
> >>  	ret = sysctl_string(&tbl, name, nlen, oldval, oldlenp, newval, newlen);
> >> -	if (ret == 0 && newval && newlen)
> >> +	if (ret == 1 && newval && newlen)
> >>  		ret = tcp_set_allowed_congestion_control(tbl.data);
> >>  	kfree(tbl.data);
> >>
> >>
> > 
> > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > This parallels previous fix by Sam Jansen.
> > 
> > 
> >From the link:http://marc.info/?l=linux-netdev&m=119551836927062&w=2,
> he only fix the sysctl_tcp_congestion_control function.
> In the latest kernel, the sysctl_string problem is present.
> Can this patch be applied?

Done.
