From: Phil Sutter <n0-1@freewrt.org>
Subject: Re: [PATCH] korina: Read buffer overflow
Date: Sat, 8 Aug 2009 18:45:05 +0200
Message-ID: <20090808164512.02C174CEAA@orbit.nwl.cc>
References: <4A7C494B.2060204@gmail.com> <20090808004815.F10394CEAA@orbit.nwl.cc> <25e057c00908080614q6d7efa3x46789e51b0b544b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, florian@openwrt.org
To: roel kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:52613 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbZHHQpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Aug 2009 12:45:11 -0400
Content-Disposition: inline
In-Reply-To: <25e057c00908080614q6d7efa3x46789e51b0b544b3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Aug 08, 2009 at 03:14:57PM +0200, roel kluin wrote:
> A few comments:
>=20
> > | diff --git a/drivers/net/korina.c b/drivers/net/korina.c
> > | index a2701f5..d1c5276 100644
> > | --- a/drivers/net/korina.c
> > | +++ b/drivers/net/korina.c
>=20
> > | @@ -772,6 +772,13 @@ static void korina_alloc_ring(struct net_dev=
ice *dev)
> > | =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lp->rd_ring[i].c=
a =3D CPHYSADDR(skb->data);
> > | =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lp->rd_ring[i].l=
ink =3D CPHYSADDR(&lp->rd_ring[i+1]);
> > | =C2=A0 =C2=A0 =C2=A0 }
> > | + =C2=A0 =C2=A0 if (!i) {
> > | + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_ERR DRV_N=
AME "%s: could not allocate a single"
> > | + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 " receive descriptor\n", dev->name)
>=20
>             printk(KERN_ERR "%s: could not allocate a single receive
> descriptor\n",
>                             dev->name);
>=20
> Don't interrupt strings, they are an exception in the 80 character
> limit (since they are easier to grep that way).

Ah, good to know.

> Also I think the DRV_NAME should be omitted, Doesn't
> `DRV_NAME "%s:...\n", dev->name)' result in "korinakorina:..."? It
> occurs at more places in the file. Also a semicolon was missing.

Sounds like a valid point, I will check this. This patch was just a
quick hack to illustrate what I had in mind, without even
compile-testing it.

> Otherwise looks fine to me.

Great you like it, and many thanks for reviewing it. I'm still not
completely sure the NIC will still work with less than 64 receive
descriptors, but since the documentation wasn't really enlightening I'l=
l
add some run-time test to my TODO. Maybe one of the other readers has
some advice here, I'll prepare a complete patch in the meantime.

Greetings, Phil


