From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Possible bug in net/ipv4/route.c?
Date: Mon, 05 Jul 2010 15:34:58 +0200
Message-ID: <1278336898.2877.212.camel@edumazet-laptop>
References: <20100705120617.GA6267@gondor.apana.org.au>
	 <1278334754.2877.173.camel@edumazet-laptop>
	 <20100705132245.GA6876@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705132245.GA6876@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 05 juillet 2010 =C3=A0 21:22 +0800, Herbert Xu a =C3=A9crit :
> On Mon, Jul 05, 2010 at 02:59:14PM +0200, Eric Dumazet wrote:
> >
> > Why do we clear full 48 bytes skb->cb[] in skb_alloc(), if no proto=
col
> > stack should rely it being zero ?
>=20
> Unless a protocol is allocating the skb itself, then the fact
> that skb_alloc clears skb->cb is no guarantee that the skb->cb
> will be zero.

I see. We could :

Avoid this memset(skb->cb, 0, sizeof(skb->cb)) in fastpath.

or in debug mode, poison it to trigger errors more often.

Thanks
