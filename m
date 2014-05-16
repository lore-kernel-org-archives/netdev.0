From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,v2] ipv4: ip_tunnels: disable cache for nbma gre
 tunnels
Date: Fri, 16 May 2014 16:59:11 -0400 (EDT)
Message-ID: <20140516.165911.11269553598440450.davem@davemloft.net>
References: <20140515.232905.995406666776115109.davem@davemloft.net>
	<1400218479-10166-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com, edumazet@google.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315AbaEPU7M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 16:59:12 -0400
In-Reply-To: <1400218479-10166-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Fri, 16 May 2014 08:34:39 +0300

> The connected check fails to check for ip_gre nbma mode tunnels
> properly. ip_gre creates temporary tnl_params with daddr specified
> to pass-in the actual target on per-packet basis from neighbor
> layer. Detect these tunnels by inspecting the actual tunnel
> configuration.
>=20
> Minimal test case:
>  ip route add 192.168.1.1/32 via 10.0.0.1
>  ip route add 192.168.1.2/32 via 10.0.0.2
>  ip tunnel add nbma0 mode gre key 1 tos c0
>  ip addr add 172.17.0.0/16 dev nbma0
>  ip link set nbma0 up
>  ip neigh add 172.17.0.1 lladdr 192.168.1.1 dev nbma0
>  ip neigh add 172.17.0.2 lladdr 192.168.1.2 dev nbma0
>  ping 172.17.0.1
>  ping 172.17.0.2
>=20
> The second ping should be going to 192.168.1.2 and head 10.0.0.2;
> but cached gre tunnel level route is used and it's actually going
> to 192.168.1.1 via 10.0.0.1.
>=20
> The lladdr's need to go to separate dst for the bug to trigger.
> Test case uses separate route entries, but this can also happen
> when the route entry is same: if there is a nexthop exception or
> the GRE tunnel is IPsec'ed in which case the dst points to xfrm
> bundle unique to the gre lladdr.
>=20
> Fixes: 7d442fab0a67 ("ipv4: Cache dst in tunnels")
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Yeah, this one compiles :-)

Applied and queued up for -stable, thanks!
