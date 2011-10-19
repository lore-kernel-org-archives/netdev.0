From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga) causes
 kernel oops
Date: Wed, 19 Oct 2011 09:18:33 +0200
Message-ID: <1319008713.17914.8.camel@edumazet-laptop>
References: <20111018114945.GA16359@gondor.apana.org.au>
	 <1318942560.2657.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111018134537.GA17055@gondor.apana.org.au>
	 <20111019.030914.218521668377472155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.hengli.com.au, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111019.030914.218521668377472155.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 19 octobre 2011 =C3=A0 03:09 -0400, David Miller a =C3=A9cr=
it :
> From: Herbert Xu <herbert@gondor.hengli.com.au>
> Date: Tue, 18 Oct 2011 15:45:37 +0200
>=20
> > On Tue, Oct 18, 2011 at 02:56:00PM +0200, Eric Dumazet wrote:
> >>
> >> I am ok by this way, but we might hit another similar problem else=
where.
> >>=20
> >> (igmp.c ip6_output, ...)
> >>=20
> >> We effectively want to remove LL_ALLOCATED_SPACE() usage and obfus=
cate
> >> code...
> >=20
> > Here's another idea, provide a helper to do the skb allocation
> > and the skb_reserve in one go.  That way this ugliness would only
> > need to be done once.
>=20
> Someone please test this:
>=20
> --------------------
> net: Fix crashes on devices which dynamically change needed headroom.
>=20
> One such device is IP_GRE.
>=20
> The problem is that we evaluate the device characteristics twice, onc=
e
> to determine the allocation size, and once to do the skb_reserve().
>=20
> Combine these into one operation using a helper function.
>=20
> With help from Eric Dumazet and Herbert Xu.
>=20
> Reported-by: Reported-by: Elmar Vonlanthen <evonlanthen@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
>=20



Seems fine (Maybe do the +15 in caller site ?), but we also have other
problematic cases, using alloc_skb() only...
