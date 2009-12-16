From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Wed, 16 Dec 2009 09:19:37 +0100
Message-ID: <1260951577.10356.60.camel@johannes.local>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
	 <1260871411.3692.4.camel@johannes.local>
	 <1260871634.3692.6.camel@johannes.local>
	 <200912151130.59103.holgerschurig@gmail.com>
	 <1260873307.3692.10.camel@johannes.local>
	 <787b0d920912152254r4bd3e1e2l14fbe7c1fdf42e60@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-AWs3j+QQv84YxKojPtJP"
Cc: Holger Schurig <holgerschurig@gmail.com>, m.hirsch@raumfeld.com,
	libertas-dev@lists.infradead.org, dcbw@redhat.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@kernel.org, daniel@caiaq.de,
	David Miller <davem@davemloft.net>
To: Albert Cahalan <acahalan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:39459 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761814AbZLPIUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 03:20:12 -0500
In-Reply-To: <787b0d920912152254r4bd3e1e2l14fbe7c1fdf42e60@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AWs3j+QQv84YxKojPtJP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-12-16 at 01:54 -0500, Albert Cahalan wrote:

> >> You therefore can't connect to the otherwise legitimate SSID of
> >> TEST\0\0\0.
> >
> > Ick! I guess your cfg80211 IBSS join handler needs to check for that
> > then and refuse such an SSID.
>=20
> No, pad the SSID out to 32 bytes and let the firmware try.

No, if we _know_ the firmware will try to connect to "TEST" instead of
"TEST\0\0\0" then refusing it is the right thing to do.

> First of all, isn't TEST\0\0\0 simply the wrong length anyway?
> (that is, a length other than 32 is nonsense AFAIK)

No.

> Second of all, even if that is valid, the firmware probably handles
> at least one SSID that starts with TEST and has some number
> of NUL bytes on the end. Since you can't tell what that would be
> with a particular firmware version, you might as well just let the
> firmware try. The worst case failure here is that there is more than
> one SSID of this form and you connect to the wrong one. If you
> have a problem with this kind of trouble then you need ethernet.

No. An SSID is a uniquely defined, 1-32 byte long byte bit pattern. It
doesn't treat \0 special in any way as your comments suggest. If the
firmware stops matching at \0, the firmware is broken and shouldn't be
given a choice.

johannes

--=-AWs3j+QQv84YxKojPtJP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLKJgVAAoJEODzc/N7+Qma3M0P/2NCMTTZEzeTn2WlVgS22Pde
GeiyL5P00X5pTOeKMFYWz8dZ27w+VeBRUrKFiFDgfNLqo8KqH0PIvFK0sIbkltls
tc9rXE8GJF6egxB3gVmiaH3iO9YSESStfTrZGVcSzuWa7ugA06TSxf4oOMZRa2as
r2+TCLEJg4eG8fD5OZJ417/j7jZiiI3oI69haE82EGcwtHTMDpsmWdHDxzzEZLDy
VES+vzKQDKW7+W3xmhylrNCxQekGOa94PJcdUSUvviH8ILtgIBH1vRI367hAO24W
gimMQBd/TQ5adI3vYuOoxiXWVOxzyUvdkmAwCTHV6xiYtS8/f8h6xc842Ws6E1lQ
rpta4peQ8B2IP0Ligz6RByXfnjKaPMS0Ud4Ucd74ThxPfmZ4hhcP96yhJu23+oHV
XbuLqchIY2sSUx7Xm+cJMDO6Zf9kXCwoi0qI5mSMzWt/fXTP6r/zIP8SI82OOsna
VVfKgnK9COSBUWUqhW4GP/MDfGqAfppjMcNJbebegJ1agiaZ3TNUdhyuF6fcNTV/
LcM4dvbaHEua42KtKmmoZfQ7z4yQ0awgXTaCGWfSEpbIcGN7UzteKMEtzWG74QfA
0zQGLPpYV987mt2ELCTI4UelM75IeBux/dvdnA9BG+fEEl0dGWZTptRFDeO1wy1p
jhiSayHpbXcpBf/2Zgv3
=CQvN
-----END PGP SIGNATURE-----

--=-AWs3j+QQv84YxKojPtJP--

