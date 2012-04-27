From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Fri, 27 Apr 2012 00:03:53 -0400 (EDT)
Message-ID: <20120427.000353.88307876739861257.davem@davemloft.net>
References: <1335289058.5205.165.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tore@fud.no, netdev@vger.kernel.org, maze@google.com,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350Ab2D0EFF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 00:05:05 -0400
In-Reply-To: <1335289058.5205.165.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Apr 2012 19:37:38 +0200

> From: Eric Dumazet <edumazet@google.com>
>=20
> Quoting Tore Anderson from :
> https://bugzilla.kernel.org/show_bug.cgi?id=3D42572
>=20
> When RTAX_FEATURE_ALLFRAG is set on a route, the effective TCP segmen=
t
> size does not take into account the size of the IPv6 Fragmentation
> header that needs to be included in outbound packets, causing every
> transmitted TCP segment to be fragmented across two IPv6 packets, the
> latter of which will only contain 8 bytes of actual payload.
>=20
> RTAX_FEATURE_ALLFRAG is typically set on a route in response to
> receving a ICMPv6 Packet Too Big message indicating a Path MTU of les=
s
> than 1280 bytes. 1280 bytes is the minimum IPv6 MTU, however ICMPv6
> PTBs with MTU < 1280 are still valid, in particular when an IPv6
> packet is sent to an IPv4 destination through a stateless translator.
> Any ICMPv4 Need To Fragment packets originated from the IPv4 part of
> the path will be translated to ICMPv6 PTB which may then indicate an
> MTU of less than 1280.
>=20
> The Linux kernel refuses to reduce the effective MTU to anything belo=
w
> 1280 bytes, instead it sets it to exactly 1280 bytes, and
> RTAX_FEATURE_ALLFRAG is also set. However, the TCP segment size appea=
rs
> to be set to 1240 bytes (1280 Path MTU - 40 bytes of IPv6 header),
> instead of 1232 (additionally taking into account the 8 bytes require=
d
> by the IPv6 Fragmentation extension header).
>=20
> This in turn results in rather inefficient transmission, as every=20
> transmitted TCP segment now is split in two fragments containing
> 1232+8 bytes of payload.
>=20
> After this patch, all the outgoing packets that includes a
> Fragmentation header all are "atomic" or "non-fragmented" fragments,
> i.e., they both have Offset=3D0 and More Fragments=3D0.
>=20
> With help from David S. Miller
>=20
> Reported-by: Tore Anderson <tore@fud.no>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =AFenczykowski <maze@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Tested-by: Tore Anderson <tore@fud.no>

Applied.
