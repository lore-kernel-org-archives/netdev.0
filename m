From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv4: use daddr to get inet_peer
Date: Fri, 14 Feb 2014 11:35:19 +0100
Message-ID: <20140214103519.GB12549@order.stressinduktion.org>
References: <52FDE10F.5010903@cn.fujitsu.com> <20140214094151.GA12549@order.stressinduktion.org> <52FDE70B.2020901@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54512 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaBNKfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 05:35:20 -0500
Content-Disposition: inline
In-Reply-To: <52FDE70B.2020901@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 05:51:07PM +0800, Duan Jiong wrote:
> =E4=BA=8E 2014=E5=B9=B402=E6=9C=8814=E6=97=A5 17:41, Hannes Frederic =
Sowa =E5=86=99=E9=81=93:
> > On Fri, Feb 14, 2014 at 05:25:35PM +0800, Duan Jiong wrote:
> >>
> >> since commit 1d861aa4("inet: Minimize use of cached route inetpeer=
"),
> >> ip_error() uses saddr to get inet_peer, so ip_error() and icmpv4_x=
rlim_allow()
> >> use the same inet_peer to limit icmp error message twice.
> >>
> >> In ip_error(), peer->rate_tokens is set to ip_rt_error_burst, but =
in
> >> inet_peer_xrlim_allow() peer->rate_tokens is set to XRLIM_BURST_FA=
CTOR.
> >> XRLIM_BURST_FACTOR is defined to 6, so user seting ip_rt_error_bur=
st makes
> >> no sense.
> >>
> >> In my opinion, the ip_rt_error_burst is used to limit icmp error m=
essages
> >> for daddr instead of saddr.
> >=20
> > Hmmm...
> >=20
> > ip_error is a dst_input function, as such it gets called with the i=
ncoming
> > packet. saddr is the address we send the reply back (see
> > icmp_send->icmp_route_lookup).
> >=20
>=20
> But if we still use saddr to get inet_peer, seting ip_rt_error_burst =
will make
> no sense, because it will be overwrited by XRLIM_BURST_FACTOR.

Sorry, I cannot follow you.

On output we refetch the inetpeer with the destination address. I don't
see how the patch helps.

Greetings,

  Hannes
