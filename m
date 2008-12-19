From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Fri, 19 Dec 2008 13:31:00 +0100
Message-ID: <1229689860.12322.13.camel@nathan.suse.cz>
References: <20081217114138.GA20976@gondor.apana.org.au>
	 <20081217125505.GA8379@ms2.inr.ac.ru>
	 <20081217221637.GA27811@gondor.apana.org.au>
	 <20081217.151713.90960645.davem@davemloft.net>
	 <Pine.LNX.4.64.0812181002380.10269@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:59141 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752721AbYLSMbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 07:31:03 -0500
In-Reply-To: <Pine.LNX.4.64.0812181002380.10269@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=C3=A4rvinen p=C3=AD=C5=A1e v =C4=8Ct 18. 12. 2008 v 22:07 +0200:
> On Wed, 17 Dec 2008, David Miller wrote:
>=20
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Thu, 18 Dec 2008 09:16:37 +1100
> >=20
> > And it also shows that our strange scheme, where we don't
> > signal URG until it's within the 16-bit sequence offset
> > limit, at least reports an accurate URG value.
>=20
> [...snip...]
>=20
> > Given all of this I still think our current compromise is likely th=
e
> > best one.  We never will advertise an URG pointer that is not point=
ing
> > to where the URG data will be in the sequence space.
>=20
> Wholeheartedly agreed, but with added note that if somebody is fool e=
nough=20
> to come up complaining about the behavior we've selected (among the p=
alette=20
> of broken ways we had available) we might actually succeed in convinc=
ing=20
> him to come up with something that has more change in working than ur=
g=20
> altogether. Sadly, urg is ABI-in-stone that must everyone must keep=20
> supporting in some crippled-form. ...But no worries, I've a solution =
below=20
> which should satisfy everybody... :-)
>=20
>=20
> --=20
>  i.
>=20
>=20
> [PATCH] tcp: fix all urg troubles for now
>=20
> Return to stone age with 64k is enough for everybody attitude
> (or was it 640k, I keep forgetting). Urg certainly works fine
> if no window scaling is not allowed ;-)
>=20
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/ipv4/tcp_input.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 99b7ecb..54fe815 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -72,7 +72,7 @@
>  #include <net/netdma.h>
> =20
>  int sysctl_tcp_timestamps __read_mostly =3D 1;
> -int sysctl_tcp_window_scaling __read_mostly =3D 1;
> +int sysctl_tcp_window_scaling __read_mostly =3D 0;

Yes, nice default, but don't you want to
remove /proc/sys/net/ipv4/sysctl_tcp_window_scaling completely? Let's
not make it possible for the admin to shoot himself in the foot by
accident... ;-))

Petr Tesarik

>  int sysctl_tcp_sack __read_mostly =3D 1;
>  int sysctl_tcp_fack __read_mostly =3D 1;
>  int sysctl_tcp_reordering __read_mostly =3D TCP_FASTRETRANS_THRESH;b

