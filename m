From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Thu, 13 Apr 2006 14:19:26 +0200
Message-ID: <1144930766.4187.80.camel@localhost>
References: <20060411085805.949313000@sipsolutions.net>
	 <20060411085841.252064000@sipsolutions.net>
	 <20060413020010.2ab16d7b.zaitcev@redhat.com>
	 <1144930375.2372.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-R6JnNNgTS9oHZJKQVGIQ"
Cc: Pete Zaitcev <zaitcev@redhat.com>, netdev@vger.kernel.org,
	linville@tuxdriver.com, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:11660 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964898AbWDMMTm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 08:19:42 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1144930375.2372.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-R6JnNNgTS9oHZJKQVGIQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-04-13 at 08:12 -0400, Dan Williams wrote:

> Maybe it's wrong now, but it's how the CLI tools have operated for quite
> a while AFAIK.

Yes, and they don't seem to care about the netlink messages.

But the question is rather -- should we block the program inside the
kernel and only return from "get scan" after the scan is actually done,
rather than returning "we can't give you anything now, try later". We
could do that too, but then the program would be blocked inside the
kernel without any chance of saying "bah, this takes too long, I'll
ignore it".

> There are two options for tools: (a) request scan and block on GIWSCAN
> until it doesn't return EAGAIN, or (b) request a scan, enter a loop,
> wait for the GIWSCAN netlink message to come back.  The point here is
> that if you have to write a tool with 100 lines of netlink message
> processing code _just_ to get the "scan done!" message, that's a bitch.
> More complicated programs can obviously do this, but simple tools don't
> want or need to.

Yeah, I just implemented that in softmac too (patch 5 of my set), so you
can just request a scan and do nothing until you are notified that the
netlink message came in that scanning is done.

> airo, atmel, and orinoco all do this.  ipw does not, and prism54 does
> not because it does background scanning.  I believe that the patch for
> softmac/bcm43xx EAGAIN is correct.

Good. I hope that these can go in before 2.6.17.

johannes

--=-R6JnNNgTS9oHZJKQVGIQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARD5By6Vg1VMiehFYAQJC2xAAkRDci1oLFBpvUW/CHCMMYp86cZaRDrJN
aR/Qj80TE1KjF5HhAGNhXEAnm0G8TluFk/24VDufa4bJhz69QGK38GEjbzP7VdHO
Ok9A2I9nQfx2upSlyZ0aDLh+QFdAsLBsIXsa99GFUBmrIcF5HNJQUEqrElXlPBQF
HotIgEhyeqgvQpy+HpQfrtW4oXnrakwNGesNfSfcsGPjD2Aw/48PJwjaRWeQh/qu
Z9QbL+fXwkEs4t5dVmkMww7WjNLJ3sYhMGZ+hrLnqW++U4TqrpTlFC2sKQhv2ggu
s38NOLvmlYLiypQRzveI7naeHvnTtKwHvfFZJzmXxL9GCpblUlKIPkF08TyCauC8
nfekCjo6e2ikzdwQowaznLpcJMLXz+42MXsWgTyGRfyK3GxfKJ4K6S09DiGvwWpW
T/UJGNgU8niyzk33laggdE8Wn1KL/Qnqt9ZQgq3Uc9RyD3SzWaJX9HLoagm007Iw
SRGO3qJEVdXL9htzJ7IPy6Q2Oiid+Urj9uKtRX4R9xoi0Mt+JZS+b0H3GQYf2IXX
QkvXR+cUDH2LiPovBW4w6KvHC5ILm/kV0yBVdCU0doQTlwByxhV+1nN+zCEX8isl
qJqrqCMf12oG2PFY7uoBmBakwj2vRQON7tys2bUSKz9jNxZFqyjwzKxktWsqkgSC
fJwJ0+0bH4I=
=S6zN
-----END PGP SIGNATURE-----

--=-R6JnNNgTS9oHZJKQVGIQ--

