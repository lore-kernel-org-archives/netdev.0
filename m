From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net/ipv4: Use next hop exceptions also for input
 routes
Date: Sun, 26 May 2013 00:03:04 -0700 (PDT)
Message-ID: <20130526.000304.483513823383996098.davem@davemloft.net>
References: <1369314946-12692-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759137Ab3EZHDF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 03:03:05 -0400
In-Reply-To: <1369314946-12692-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 23 May 2013 16:15:46 +0300

> Commit d2d68ba9 (ipv4: Cache input routes in fib_info nexthops)
> assmued that "locally destined, and routed packets, never trigger
> PMTU events or redirects that will be processed by us".
>=20
> However, it seems that tunnel devices do trigger PMTU events in certa=
in
> cases. At least ip_gre, ip6_gre, sit, and ipip do use the inner flow'=
s
> skb_dst(skb)->ops->update_pmtu to propage mtu information from the
> outer flows. These can cause the inner flow mtu to be decreased. If
> next hop exceptions are not consulted for pmtu, IP fragmentation will
> not be done properly for these routes.
>=20
> It also seems that we really need to have the PMTU information always
> for netfilter TCPMSS' clamp-to-pmtu feature to work properly.
>=20
> So for the time being, cache separate copies of input routes for
> each next hop exception.
>=20
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Thanks for working on this Timo, I am actively reviewing this change
and thinking about alternatives.
