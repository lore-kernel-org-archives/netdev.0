From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Fri, 12 Jul 2013 10:51:13 +0200
Message-ID: <20130712085113.GI12611@order.stressinduktion.org>
References: <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com> <20130710212149.GA26122@order.stressinduktion.org> <51DE671F.5050706@6wind.com> <20130711102441.GC5207@order.stressinduktion.org> <20130711144623.GA5707@order.stressinduktion.org> <51DEC7E6.8000500@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:40980 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757397Ab3GLIvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 04:51:14 -0400
Content-Disposition: inline
In-Reply-To: <51DEC7E6.8000500@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Nicolas,

On Thu, Jul 11, 2013 at 04:57:42PM +0200, Nicolas Dichtel wrote:
> Le 11/07/2013 16:46, Hannes Frederic Sowa a =C3=A9crit :
> >On Thu, Jul 11, 2013 at 12:24:41PM +0200, Hannes Frederic Sowa wrote=
:
> >>I fear, I'll need to do a bit more research.
> >
> >My proposal is to take my patch and check for RTF_ADDRCONF plus=20
> >RTF_DYNAMIC,
> >too. The RTF_DYNAMIC check would prevent routes created from icmpv6=20
> >redirects
> >entering an ecmp route set.
> >
> >Do you agree?
> Yes.

There is still some window where things go wrong now, I fear. If we hav=
e ecmp
routes active and we update the pmtu of that rt6_info, we might end up =
with a
route in the ecmp set, which might not get recountet if another ecmp ro=
ute
joins the set. I will have to think how to deal with this. Do you have =
an
idea?

Thanks,

  Hannes
