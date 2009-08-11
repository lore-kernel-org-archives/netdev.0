From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] mac802154: add a software MAC 802.15.4
 implementation
Date: Tue, 11 Aug 2009 22:39:58 +0200
Message-ID: <1250023198.13529.69.camel@johannes.local>
References: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com>
	 <1249913800-10176-2-git-send-email-dbaryshkov@gmail.com>
	 <1249914466.32614.13.camel@johannes.local>
	 <20090811202304.GA6303@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-3XFb+xCY3QrPecNgVeor"
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Sergey Lapin <slapin@ossfans.org>
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:53792 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbZHKUkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 16:40:07 -0400
In-Reply-To: <20090811202304.GA6303@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3XFb+xCY3QrPecNgVeor
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-08-12 at 00:23 +0400, Dmitry Eremin-Solenikov wrote:

> > That return value is strange.
>=20
> The idea is that tx function can return info about errors during
> transmit (busy channel, no ACK, etc).

Well, TX functions don't usually wait for anything so busy channel or no
ack wouldn't be possible to return there but more like a TX status, and
I think people are more used to NETDEV_TX_OK etc. return values. But
it's your choice to make, obviously. If you want to return specific
information like that though I would recommend making an enum so you get
at least some type checking (and things like 'return -1' are more
obviously wrong).

> > We've had no end to trouble with the master netdev, I suggest you look
> > into the current mac80211 code and see if you can get rid of it.
>=20
> What troubles w/ master netdev did you have had? I do still see the
> master devices in mac80211. IIUC, it's planned to replace (from
> management point of view) the mdev with wiphy instance, isn't it?

Mostly the userspace API was a mess, and you can't actually _do_
anything with the master netdev. It also doesn't see all the frames,
only outgoing. It's very strange.

Yes, you still see it in the current tree, but it's gone in our -next
tree.

The biggest problem is that it really clutters up the userspace API
since you can't do any netdev things with it, it's just a placeholder.

In addition to that, you can't put anything into skb->cb, then push the
frame to the master netdev, and expect things in skb->cb to still be
there when the frame arrives at the master netdev. Not sure you do that
(I hope not because that would be very buggy), but eventually you'll
probably find that you do want that, etc.

IMHO it's just better practise to not use it in situations like this
where it can't be really used as a netdev.

> Hmm. I thought that one may be able to rmmod the module w/ ops while the
> device is still hanging in the system. On the other hand, ops are
> provided by the driver, so if one rmmods the driver and the device is
> still there, it's a bug...

Exactly. You _want_ to be able to rmmod the module and have it
unregister itself.

johannes

--=-3XFb+xCY3QrPecNgVeor
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKgdcbAAoJEODzc/N7+QmaUecP/juwhZgk9VktoKojRaVQfvUg
6eTohSpwoyaqlc2zvzJf81+bZIcuVBXasM0dQed/0ZBsKd/C/vKcXc4HLfoLeaf1
9X84eD8LomW16XyFr0PSfTvO7UWeinKAOThWbd5GyX/jWkRmL/89mDUVwRe/jvxQ
WII5NOotxgZBOU2GAu3Z5zGpz8HstcH1YTGxSn7yooWEIHPjzBNeYQPf6FbV5QIr
30yAppCj4jTEV45f63MJjV7TUtnt0DxUtDKDiNxSqPxtpo1KcoD4mM+BaYYGlnsw
ICnKny/NXt6Z5ykDTB8c9hWxCe4xzygeoMORhhrmVIEYHdg2SnbZ2YOrlP3bmj3W
Jh/sDCRtIS3KTwL38Q8yym4bzIcnWKVcUGHuKfFU1SMN52JNk0Pu8SCv+un4RezQ
Hw26+pCRNqftoDPMMPGGMpUd9rIxsBZejb5XFeCAFn5l8bu1geO59vXT5v7ZXlEU
Hef1F/H60ezGwOEzmSeObhSjvVjBARZhz99Qe6t0Dc8GD39brjuxllHuc8P2zmYn
b5jSrz7B8LaV5psFxIhxOwX0WxEcbt83bnUspvFaA4fEIyv/7kpZEOacyNHkdJm9
9ZWJSaYsSzy5+WOGbFX7xLtkDsfAyZMnJe0+pEqkaN+nZ8UnCQGPfc1S3Peq5LaM
Tr1k9aNvgFK+9LMrSgpN
=gPG7
-----END PGP SIGNATURE-----

--=-3XFb+xCY3QrPecNgVeor--

