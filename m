From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] SSB: make it depend on PCI
Date: Thu, 06 Nov 2008 12:22:53 +0100
Message-ID: <1225970573.3619.208.camel@johannes.berg>
References: <1225965082-31462-1-git-send-email-vapier@gentoo.org>
	 <1225969620.3619.204.camel@johannes.berg>
	 <8bd0f97a0811060315j7d11e1a7p257a4a1bea640f7b@mail.gmail.com>
	 (sfid-20081106_121527_240627_B635B0E2)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-FLru3HycblWMZUMmVFT2"
Cc: Mike Frysinger <vapier@gentoo.org>, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33629 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753494AbYKFLW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 06:22:56 -0500
In-Reply-To: <8bd0f97a0811060315j7d11e1a7p257a4a1bea640f7b@mail.gmail.com> (sfid-20081106_121527_240627_B635B0E2)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FLru3HycblWMZUMmVFT2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-11-06 at 06:15 -0500, Mike Frysinger wrote:

> while that may be the intent, it doesnt work today.
>=20
> drivers/ssb/main.c always includes linux/ssb/ssb.h
>=20
> linux/ssb/ssb.h always calls pci_dma_* functions
>=20
> arches that do not support PCI fail to build:
>   CC      drivers/ssb/main.o
> In file included from drivers/ssb/ssb_private.h:5,
>                  from drivers/ssb/main.c:12:
> include/linux/ssb/ssb.h: In function 'ssb_dma_mapping_error':
> include/linux/ssb/ssb.h:430: error: implicit declaration of function 'pci=
_dma_mapping_error'
> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_for_cpu':
> include/linux/ssb/ssb.h:475: error: implicit declaration of function 'pci=
_dma_sync_single_for_cpu'
> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_for_device':
> include/linux/ssb/ssb.h:493: error: implicit declaration of function 'pci=
_dma_sync_single_for_device'
> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_range_for_cpu':
> include/linux/ssb/ssb.h:517: error: implicit declaration of function 'dma=
_sync_single_range_for_cpu'
> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_range_for_devic=
e':
> include/linux/ssb/ssb.h:538: error: implicit declaration of function 'dma=
_sync_single_range_for_device'
> drivers/ssb/main.c: In function 'ssb_dma_set_mask':
> drivers/ssb/main.c:1183: error: implicit declaration of function 'dma_set=
_mask'


That seems odd, shouldn't at least the dma_sync_* functions and
dma_set_mask be supported?

There probably need to be ifdefs, if you look at those functions then
you'll see that it depends on the bustype the device is on.

johannes

--=-FLru3HycblWMZUMmVFT2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJEtOIAAoJEKVg1VMiehFYX3UP+wc4A8g2LLmsoKIgpFq8Nit+
lqpz3ac6WyupuG4q5r6kHJsdDJrY59n4Q6ZUkAM5FT6j6+cIqE+30tRf+Oqdujtw
wi5Iho1l4nFPglGizOi7X08QTGa89PhSw2kheSR+sFSe7GDx6GYXTFXzGhxDQoK5
eDNkMa9f8D2vzxrs1LnaFlVkfeqldStzcb3KnBArfkC6BwOFJQ6XdGRGl4lAPVaQ
+4JJat09YRSXCS9E3SGXOABcVwFh+wL8GHCGm+2DbxMEcPmgXy8IQsvpaqNiJcIl
uTFBVCWnU8YwaeSjmi65hKy9pW/iYUBVskyc8R8FHYeHQ5g0RzHwJGl58oZMTwzT
AnRgbtqeE6qIkxMJ/xx9oouCts/+Px7Y5KkhjXwDSR6stJijUldDAOWPpEzSvYCH
F0OX1lGBM7qOJQ8bQTFIAiPsjL6C/mdfGvy7Roxg0lxr3+b+A5KIjf+1mLJo8Xui
Mn/Ev5Fij1H4vcFNmuL7svASBJjCS/c5MVNHCuj8D3BImD9gbS23sXCDX20pxu0x
WCqoiRG0rn+ZDPPpnKpyfecR9fvCyfFSSOUlzVtVCT+ny6GuQ20MNHO5xu8sdzH4
3WrqtQL5wN1fNyR+emkuW8v8G0BZmdrw/xploZAUT0TqnfJ4pJd325r81zKQHdn3
qt6bMTxbyotkrcvq59pz
=8x3R
-----END PGP SIGNATURE-----

--=-FLru3HycblWMZUMmVFT2--

