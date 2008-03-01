From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: RFC [PATCH 3/3] TCP_DEFER_ACCEPT updates: more accurate timers
	and	resets
Date: Sat, 01 Mar 2008 15:59:02 -0500
Message-ID: <1204405142.5792.26.camel@tng>
References: <1204076973.15970.37.camel@tng> <47C935BC.9060409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <dada1@cosmosbay.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from linode.ducksong.com ([64.22.125.164]:44253 "EHLO
	linode.ducksong.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756723AbYCAU65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 15:58:57 -0500
In-Reply-To: <47C935BC.9060409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2008-03-01 at 11:53 +0100, Eric Dumazet wrote:
> Patrick McManus a =E9crit :
> > Signed-off-by: Patrick McManus <mcmanus@ducksong.com>
> >=20
> >   Change TCP_DEFER_ACCEPT implementation so that it transitions a
> >     connection to ESTABLISHED after handshake is complete instead o=
f
> >     leaving it in SYN-RECV until some data arrvies. Place connectio=
n in
> >     accept queue when first data packet arrives from slow path.
> >
> This all makes sense Patrick.
>=20
> Your patch is quite large and difficult to review (for me :) )
>=20

Eric, thanks for the feedback!

> 1) Adding "struct tcp_deferred_accept_info" on "struct tcp_sock" (24 =
bytes on=20
> 64 bit arches) is a rather high cost to pay for an obscure TCP_DEFER_=
ACCEPT.
>=20
> But then, many "struct tcp_sock" fields are used only at socket estab=
lishment.
>=20

It occurs to me the child socket pointer in that struct is superfulous,
so I can cut it down to two ptrs instead of three.. I'll include that i=
n
a respin - and as you point out struct tcp_sock is already full of stuf=
f
that is really only used once.

> 2) About MAX_TCP_ACCEPT_DEFERRED test in do_tcp_setsockopt(), I am no=
t sure we=20
> can return -EINVAL.
>=20

> setsockopt(TCP_DEFER_ACCEPT, 100000) is a hint given by application, =
and could=20
> be mapped to setsockopt(TCP_DEFER_ACCEPT, 65535) silently.

good point, I agree. I'll include that change in the respin too.


-Patrick


