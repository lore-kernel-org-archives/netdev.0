From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Fri, 12 Jul 2013 18:19:35 +0200
Message-ID: <20130712161935.GB31912@order.stressinduktion.org>
References: <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com> <20130710212149.GA26122@order.stressinduktion.org> <51DE671F.5050706@6wind.com> <20130711102441.GC5207@order.stressinduktion.org> <20130711144623.GA5707@order.stressinduktion.org> <51DEC7E6.8000500@6wind.com> <20130712085113.GI12611@order.stressinduktion.org> <51DFF0DD.5050601@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:41837 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932823Ab3GLQTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 12:19:36 -0400
Content-Disposition: inline
In-Reply-To: <51DFF0DD.5050601@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 02:04:45PM +0200, Nicolas Dichtel wrote:
> It's possible to add a glue to check this counter when we play with these 
> flags, but it's ugly.
> 
> Maybe the check against RTF_EXPIRES is fundamentally wrong. Checking 
> RTF_ADDRCONF|RTF_DYNAMIC should be enough, what do you think?

Yes, this seems to be the best option now. I will audit the source if
RTF_ADDRCONF and RTF_DYNAMIC are immutable after dst construction and
if other errors could arise for that and would go with this solution then.

What do you think about making ecmp routes explicit by adding RTF_ECMP
flag?

> In another hand, we can discuss about the initial assumption, that was 
> "only static routes are part of ECMP routes". I'm thinking of what are the 
> consequence if we accept to accept all routes, without checking any flags.

I don't have a good feeling about that. But I may be wrong.

Greetings,

  Hannes
