From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] mac802154: add a software MAC 802.15.4
 implementation
Date: Wed, 12 Aug 2009 15:13:57 +0200
Message-ID: <1250082837.8784.21.camel@johannes.local>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com>
	 <1249913800-10176-2-git-send-email-dbaryshkov@gmail.com>
	 <1249914466.32614.13.camel@johannes.local>
	 <20090811202304.GA6303@doriath.ww600.siemens.net>
	 <1250023198.13529.69.camel@johannes.local>
	 <20090812130605.GA17169@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-4xkkTI3pjNNfpRSvxoZh"
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Sergey Lapin <slapin@ossfans.org>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:45497 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbZHLNOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 09:14:31 -0400
In-Reply-To: <20090812130605.GA17169@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4xkkTI3pjNNfpRSvxoZh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-08-12 at 17:06 +0400, Dmitry Eremin-Solenikov wrote:

> > In addition to that, you can't put anything into skb->cb, then push the
> > frame to the master netdev, and expect things in skb->cb to still be
> > there when the frame arrives at the master netdev. Not sure you do that
> > (I hope not because that would be very buggy), but eventually you'll
> > probably find that you do want that, etc.
>=20
> Hmm. It works for us. Could you please tell me more about the problems
> with skb->cb ?

Uh, well, you don't own the skb->cb between dev_queue_xmit() and
ndo_start_xmit(). In fact, your phy_cb data will be overwritten by the
qdisc.

So your code is completely and utterly broken just like mac80211 was for
a long time.

Also, looking into this a bit more, I see no reason to allocate a work
struct every time you get a frame -- better just queue them up and stick
everything else into skb->cb. In fact, you don't need a master netdev
here anyway, just move all code from ieee802154_master_hard_start_xmit()
into ieee802154_net_xmit().

johannes

--=-4xkkTI3pjNNfpRSvxoZh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKgsASAAoJEODzc/N7+Qma1iwP/1/hQZ1LeYX5v4mwqN69nqV/
mTvn2qoyfi3As4hiuf/9OrDsvCj1fAbcGO8tgGlmOs3wvt+zAN0ZVtS99F8weZWI
6U7EB65orKfqR1aTPFG7oIzBNu/YqngAk479PJcYWNNyNmQJBromn7sKEMEDBzey
cwALVhWEmQpMOe0gQOk9Ro7o37QEiFVIIWOaSf41sceGwEXSgufr4s/w9CweoIu9
Jo1Vqz43wO5jfcmCc3Zqe0cUhVUmg+tIdEyXugnV5K7LR0WucEA9Z4hFIYgSzHTW
PdXDmMfuWFIt0/zTrYkjPEsuHbB/24pdspa/lei6HuXotSiEftBTg1e3pGP5ig84
DzdH1E675m7PV6uGQY6ooV/Pu4X69vE21rRZjEyZS1rmthWXpI6MaQZFfUKw8CnF
Fkm+6mMAHDg7crWMbp0K/DHPXbGjyQ1kLI0RFBEket6CjOnsvos87aKmlwZkqbfR
4qyEw5xpUPC9UEVSTueOLrddSzfpRyBWaTAxa9xHSNeLjPohUCt7PjTh7cSA510Q
OxNylGGALMspKao8sw+SbKtzGzA68IQHyEGWf5BXhK+x2tf4DP2dMn5AWE3MNw7D
mmkby78NOgZ5nZRkl3OEzA3lTPhnv/+zkI1qu3Xare++6V7nytpPo6WTtSq1+f3W
lGWThUeZ4xmDd1HTfwOM
=Ihhq
-----END PGP SIGNATURE-----

--=-4xkkTI3pjNNfpRSvxoZh--

