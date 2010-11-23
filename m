From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: addrconf: refcnt with  IPV6_PRIVACY enabled
Date: Tue, 23 Nov 2010 16:08:57 +0100
Message-ID: <1290524937.3046.33.camel@edumazet-laptop>
References: <20101123134003.GB4142@swordfish.minsk.epam.com>
	 <1290522803.3046.11.camel@edumazet-laptop>
	 <20101123145331.GA4102@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101123145331.GA4102@swordfish.minsk.epam.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 23 novembre 2010 =C3=A0 16:53 +0200, Sergey Senozhatsky a =C3=A9=
crit :
> =20
> > ipv6_regen_rndid() is the timer handler function, it must call
> > in6_dev_put() at the end, unless we rearm the timer.
> >=20
> > So this code is correct.
> >=20
> >=20
> > if (!mod_timer(&idev->regen_timer, expires))
> > 	in6_dev_hold(idev);
> > ...
> > in6_dev_put(idev);
> >
>=20
> Even if in6_dev_hold hasn't been called from ipv6_regen_rndid?
>=20


Yes.

Rules are :

in6_dev_hold() when arming timer, so that device doesnt disappear while
timer handler might run and need it.

in6_dev_put() when timer handler finishes
