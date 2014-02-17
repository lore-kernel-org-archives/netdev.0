From: Steven Barth <cyrus@openwrt.org>
Subject: Re: [PATCH v2] ipv6: fix inconsistent prefix route handling
Date: Mon, 17 Feb 2014 15:23:34 +0100
Message-ID: <53021B66.3000101@openwrt.org>
References: <20140216165128.GF8634@order.stressinduktion.org> <5301AF26.7080102@openwrt.org> <20140217130557.GC22833@order.stressinduktion.org> <53020AF7.60702@openwrt.org> <20140217140826.GD22833@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chi.subsignal.org ([188.40.166.11]:41243 "EHLO
	chi.subsignal.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbaBQOXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 09:23:40 -0500
In-Reply-To: <20140217140826.GD22833@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.02.2014 15:08, Hannes Frederic Sowa wrote:
>
> I fear there is currently no combination of ifp->flags which can test for
> that. Your first patch seems to be too dangerous in removing neighbour
> discovery brought in on-link state, I fear. It may even be a problem for
> permanent ones, but that's how it is done, currently.
Yeah the kernel neighbor discovery support is a bit tricky in itself and 
I found myself working around it more often then actually using it (at 
least when doing router-stuff).

>
> Best option would be to fully decouple prefix routes from address handling,
> but that would break current userspace.
>
> Current iproute has support for no-prefix-route address addition (see
> iproute2 commit 58c69b226fb3a ("add support for IFA_F_NOPREFIXROUTE")), so you
> could manage those address and route combination directly from user space.
OK, I will use a workaround for now that removes and readds addresses 
when they should be deprecated instead of just converting permanents to 
non-permanents and maybe later use that new NOPREFIXROUTE feature which 
should come in handy.

>
> So if we want to clean up those routes we either must set IFA_F_PERMANENT to
> the ifp flags of the address in inet6_addr_add and really make sure nothing
> breaks because of this. Or introduce a new flag, like IFA_F_USERINSTALLED e.g.
OK, I will try to think about this when I have some more time to spare 
on this.
Thanks for your help so far.

Steven
