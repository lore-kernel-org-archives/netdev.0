From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.29-rc5-git3 Leak r=1 3
Date: Sat, 21 Feb 2009 23:57:24 -0800 (PST)
Message-ID: <20090221.235724.207966342.davem@davemloft.net>
References: <Pine.LNX.4.64.0902201805400.31742@wrl-59.cs.helsinki.fi>
	<200902201812.47205.denys@visp.net.lb>
	<Pine.LNX.4.64.0902211324460.20284@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40465
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752355AbZBVH5n convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2009 02:57:43 -0500
In-Reply-To: <Pine.LNX.4.64.0902211324460.20284@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 21 Feb 2009 13:44:27 +0200 (EET)

> [PATCH] tcp: fix retrans_out leaks in shifting code
>=20
> There's conflicting assumptions in shifting, the caller assumes
> that dupsack results in S'ed skbs (or a part of it) for sure but
> never gave a hint to tcp_sacktag_one when dsack is actually in
> use. Thus DSACK retrans_out -=3D pcount was not taken and the
> counter became out of sync. Remove obstacle from that information
> flow to get DSACKs accounted in tcp_sacktag_one as expected.
>=20
> Compile tested only.
>=20
> In general the call to tcp_sacktag_one with the later full shift
> from already SACKed skb should not be there, it's just doing
> duplicating work already done earlier so it just wastes cycles and
> also seems to duplicate small amount of code unnecessarily :-/.
> However, moving tcp_sacktag_one call one level up is not what I want
> to do in mainline -rc5, the counting & seqno state manipulation that
> is going on there is just too hairy to get right in a hurry (order
> is very significant there as the state transition is in progress
> making normal invariants are not to be trusted). Luckily
> tcp_sacktag_one is effectively a no-op atm with dup_sack set to 0
> for already SACKed skb.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Can you do some testing on this before I toss it into
net-next-2.6? :-)  It looks fine to be, but... so did
Herbert's URG change :)
