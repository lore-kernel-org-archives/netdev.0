From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when
 real-servers are removed
Date: Thu, 31 May 2007 03:21:40 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0705310239240.3745@u.domain.uli>
References: <Pine.LNX.4.58.0705160012470.2626@u.domain.uli>
 <Pine.LNX.4.58.0705181043390.2665@u.domain.uli> <20070518.020525.28394540.davem@davemloft.net>
 <200705301138.29582@nienna>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	horms@verge.net.au, jkrzyszt@tis.icnet.pl, netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:4772 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751238AbXEaAWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 20:22:30 -0400
In-Reply-To: <200705301138.29582@nienna>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 30 May 2007, KOVACS Krisztian wrote:

>   I'm just about to publish the next round of tproxy patches (with the 
> routing code modifications completely removed), but this issue is still 
> present.
> 
>   I've posted a few patches making omitting this check possible 
> selectively back in March. Do those changes look acceptable?
> 
>   http://marc.info/?l=linux-netdev&m=117310979823297&w=3

	Just a small note for now:

	The code
	'if (dev_out == NULL && !(oldflp->flags & FLOWI_FLAG_TRANSPARENT))'
can lead to problem in 'fl.oif = dev_out->ifindex;' if fl4_src is not
present.

	Also, i'm not sure if FLOWI_FLAG_TRANSPARENT should cause
different values for flags to be cached many times. Users without this
flag get EINVAL when fl4_src is not configured, other failures are not 
cached too. And as fl4_src is considered in both cases (both kinds of 
callers get same path on success) we don't need changes except in 
ip_route_output_slow()? By this way I hope we can avoid any possible 
forking of cache entries just by different flags.

	Then we can use some more generic name, only for the flowi flag,
eg. FLOWI_FLAG_ANYSRC or something better?

