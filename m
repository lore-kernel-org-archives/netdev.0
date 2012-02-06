From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 06 Feb 2012 18:07:02 +0100
Message-ID: <1328548022.2220.87.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120206.113145.1284864994961472499.davem@davemloft.net>
	 <1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120206.115859.1384761795375582044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ogerlitz@mellanox.com, sean.hefty@intel.com,
	herbert@gondor.hengli.com.au, linux-rdma@vger.kernel.org,
	shlomop@mellanox.com, roland@kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49709 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755337Ab2BFRHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 12:07:05 -0500
In-Reply-To: <20120206.115859.1384761795375582044.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 11:58 -0500, David Miller a =C3=A9=
crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 06 Feb 2012 17:47:14 +0100
>=20
> [ Roland Dreier CC:'d ]
>=20
> > gro_max_header_len can be different than hard_header_len because as=
 Or
> > Gerlitz said :
> >=20
> > 	IPoIB advertizes hard_header_len which is bigger than the
> > 	IPoIB header len, this is done such that skbs sent by the
> > 	network stack have enough headroom for a "pseudoheader"
> > 	which for few flows (e.g unicast arp replies and multicast)
> > 	is placed there by the ipoib hard_header function and later
> > 	used by the xmit function.
>=20
> Translation: IPoIB's path resolution mechanism is garbage
>=20
> So if IPoIB path resolution was properly integrated into the neighbou=
r
> cache state machine, instead of being implemented awkwardly in the
> device transmit path, this crap wouldn't be necessary right?
>=20
> So here we have yet another incredibly painful side effect of how
> IPoIB path resolution works.
>=20
> Roland, I want you to seriously consider a way, any way, to get rid o=
f
> how IPoIB does path resolution.  It must be fully integrated into the
> neighbour layer, the neighbour layer must be knowledgable about how
> path resolution is a necessary step for a neighbour entry to enter th=
e
> valid state, and I want all of this awkward neighbour handling code
> removed from the transmit path of IPoIB.
>=20
> And finally it must not lie about it's hardware header length.
>=20
> Then we won't need crap like what is being proposed here, a
> "no_this_is_the_real_hard_header_len" struct member.  That's just
> rediculious.

OK, I'll resend my first patch then, using hard_header_len
