From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Wed, 07 May 2008 13:52:13 +0200
Message-ID: <1210161133.5642.19.camel@johannes.berg>
References: <20080430124055.091382000@sipsolutions.net>
	 <20080430130050.105344000@sipsolutions.net>
	 <20080507071026.GA24407@gondor.apana.org.au>
	 <1210150217.9305.39.camel@johannes.berg>
	 <20080507090040.GA25186@gondor.apana.org.au>
	 <1210159339.5642.13.camel@johannes.berg>
	 <20080507114123.GA26073@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-usxbYSm5s0PU7LrcAbWu"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Ron Rindjunsky <ron.rindjunsky@intel.com>,
	Tomas Winkler <tomasw@gmail.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:60589 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566AbYEGLw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 07:52:57 -0400
In-Reply-To: <20080507114123.GA26073@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-usxbYSm5s0PU7LrcAbWu
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-05-07 at 19:41 +0800, Herbert Xu wrote:
> On Wed, May 07, 2008 at 01:22:19PM +0200, Johannes Berg wrote:
> >
> > +	if (unlikely(netif_queue_stopped(local->mdev) ||
> > +		     __ieee80211_queue_stopped(local, control->queue)))
> > +		return NETDEV_TX_BUSY;
>=20
> Returning busy should be avoided because not everything expects it.

Hmm. Why does busy exist then? Historical accident? I really really
don't want to keep all that logic that does "if device enables queue
then first check if maybe we have pending packets and try to send them
and then go back to the regular queues and see if ..."

> Besides, I'm not sure if this will even work if you're fiddling
> with skb->next.  Perhaps you can stash it in a pointer local to
> your device.

You're looking at an internal helper function that is never called with
skb->next assigned; if it returns BUSY for a fragmented skb then later
in __ieee80211_tx() I will store the fragmented frame away and return
OK.

But if I really need to avoid returning busy I need to hook into all the
queue management stuff which I'd like to avoid.

johannes

--=-usxbYSm5s0PU7LrcAbWu
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASCGX7KVg1VMiehFYAQI8Ew/8D195gsMppAJCXr/zoj5y3kYbU8v82oGI
bZx7j3UqNbEhBnxy+njFSdIeO0DSmEl6sGLlsMXARhTo+iE5i9plR/CWhGInz92K
hp/UJq6FBZMVAY5gyjmEO2fl5Wrf+sBDHWoGlEw0hdoCEHI2BzbgvBTeT1kuUFn3
fCIIYOEfPRRCU5XzUr0mZH3RHxk//yoC4TVxnTLH7XsxqgJh4qYw6Sf9uoOzgHwL
Yh5y4bhk87pRWxly+FDb0k8H5TXjCM1EctY7VgkiifPE9GOS+ILiRiLxNQqKzeoH
1S36tCXpsXL4Dw4vslbZCM+JIouh1vhFvmkxC1/pKRuB9bRV+0Ln4O1s/HAjLXfg
HY9Fss4JaP0IH/YHyhWVPW8dfEizH17Mav1MIz2PjWEikKSTYxFKIxULs46emndw
QSbrvHaqOygtfkPEZxKXqAwdRO/3pZSsZGC73y2kif3I09Cm2skDCVJLUG1+smk5
yAD1MKa2UJ8S05PDj33BuBCYXgcfCNwSpWhdBjgqHDtUX15J02lPFgoCz70L+xE7
ZpWZN7OpQwkWcdCk3PQ3JW3CHlhtJeDDdu1WX0/cCKPmWNMxu5Z8irWLJAvLqt6o
s1P32p9t3IrmRdcWY0hwSk3PbBHeUknV5Yj6N9bzClaVwTNsw4CPCtSdXoljgb1i
oLIHsYza/Ys=
=OAqN
-----END PGP SIGNATURE-----

--=-usxbYSm5s0PU7LrcAbWu--

