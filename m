From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
 ip_fragment
Date: Tue, 31 Aug 2010 11:17:51 +0200
Message-ID: <1283246271.2550.35.camel@edumazet-laptop>
References: <20100830200917.GA10754@stratus.com>
	 <1283204118.2405.32.camel@edumazet-laptop>
	 <20100830232147.GB10754@stratus.com>
	 <1283232031.2405.38.camel@edumazet-laptop>
	 <20100831082444.GB29281@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100831082444.GB29281@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 31 ao=C3=BBt 2010 =C3=A0 16:24 +0800, Herbert Xu a =C3=A9crit =
:
> On Tue, Aug 31, 2010 at 07:20:31AM +0200, Eric Dumazet wrote:
> > Le lundi 30 ao=C3=BBt 2010 =C3=A0 19:21 -0400, Bandan Das a =C3=A9c=
rit :
> > > >=20
> > > > I wonder if we want this.
> > > >=20
> > > > Maybe setting skb->local_df =3D 1 in bridge should be enough ?
> > > >=20
> > > >=20
> > > Thanks Eric for looking at this. Indeed, setting local_df to 1 se=
ems to be enough! I will
> > > respin and post a different patch.
> > >=20
> >=20
> > Reading this stuff again, I wonder if we should not revert commit
> > 17762060c25590bfddd  and use a different trick
>=20
> I don't quite understand the problem.  Does the packet actually
> have IP options? If not why is it trying to look at IP options?
>=20
> If it does have options, then we should parse options in the
> bridge driver before passing it to the IP stack (or just drop
> the packet).

Once again, the IP stack -> bridge -> IP stack flow bites us,
because bridge likes to dirty IPCB.

We can correct every bug we find once in a while (you did in commit
17762060c255 for a particular bug), or just make bridge not touch IPCB.
