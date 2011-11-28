From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() wrong access to
 sk_route_caps
Date: Mon, 28 Nov 2011 08:54:15 -0800
Message-ID: <1322499255.2024.22.camel@Joe-Laptop>
References: <1322476067.2292.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1322477197.2024.4.camel@Joe-Laptop>
	 <1322496298.2292.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49666 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751531Ab1K1QyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 11:54:16 -0500
In-Reply-To: <1322496298.2292.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-28 at 17:04 +0100, Eric Dumazet wrote:
> Le lundi 28 novembre 2011 =C3=A0 02:46 -0800, Joe Perches a =C3=A9cri=
t :
> > On Mon, 2011-11-28 at 11:27 +0100, Eric Dumazet wrote:
> > > +	sg =3D !!(sk->sk_route_caps & NETIF_F_SG);
> > As sg is now bool, using !! is unnecessary.
> > A commit was done recently to remove one.
> > 3ad9b358e03fd9dbf6705721490c811b666b0fe2
> Hmm... I find it dangerous and error prone. Obviously not at the time=
 we
> commit such changes, but later, because a future reader might be fool=
ed.
> Using !!(expr) is pretty clear about the potential problem, and
> generates no extra code if a bool is used for the target.

Though I don't think
	bool =3D expr;
is particularly error prone,
spatch shows 58 uses of
	bool =3D !!expr;
in net-next drivers/net.

It might be useful to standardize on either the
implicit or explicit !! style.

I think !! is an intentional and sensible style
and should be the preferred use.

Perhaps a checkpatch warning should be issued
when the implicit cast is used.
