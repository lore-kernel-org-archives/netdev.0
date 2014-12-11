From: Kevin Hao <haokexin@gmail.com>
Subject: Re: [PATCH net] gianfar: Fix dma check map error when DMA_API_DEBUG
 is enabled
Date: Thu, 11 Dec 2014 10:06:46 +0800
Message-ID: <20141211020646.GB18701@pek-khao-d1.corp.ad.wrs.com>
References: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
 <1418135075-17349-1-git-send-email-claudiu.manoil@freescale.com>
 <20141210.131347.2165044584202384761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DIOMP1UsTsWJauNi"
Cc: claudiu.manoil@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:44555 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932937AbaLKCGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 21:06:54 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so1980218pdi.7
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 18:06:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141210.131347.2165044584202384761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DIOMP1UsTsWJauNi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 10, 2014 at 01:13:47PM -0500, David Miller wrote:
> From: Claudiu Manoil <claudiu.manoil@freescale.com>
> Date: Tue, 9 Dec 2014 16:24:35 +0200
>=20
> > From: Kevin Hao <haokexin@gmail.com>
> >=20
> > We need to use dma_mapping_error() to check the dma address returned
> > by dma_map_single/page(). Otherwise we would get warning like this:
>  ...
> > For TX, we need to unmap the pages which has already been mapped and
> > free the skb before return. For RX, just let the rxbdp as unempty.
> > We can retry to initialize it to empty in next round.
> >=20
> > Signed-off-by: Kevin Hao <haokexin@gmail.com>
> > Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
>=20
> The RX behavior needs to be adjusted.
>=20
> You should never leave holes in the RX ring, ever.
>=20
> Instead, try allocating the new RX skb first, and only if
> you are successful should you pass up the original SKB.  If
> it fails, then reuse the original SKB in the RX ring.

OK, will do.

Thanks,
Kevin

--DIOMP1UsTsWJauNi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBAgAGBQJUiPw2AAoJEJNY7TDerrFxTOkH/1D37oJXSXW6+Qq0uH/96qQh
NuwMRxE30EaDEWT/eYgvNEaHNcBdv+ve9AtjjeEGVSGDMwKgHkxVmvsajeffYilF
N7Izzn435EYdiyC4YmyCvIhCYzYx/ZgZWcnKTwIl/WvRodB3QXsbYsSP/DQ2X0l/
0xqNFHhrY0OtQaId4+pGslIpEIuKo8M172qsJ0AdW5Omep0nbzC1hi31uEsKs86a
T7xbAhIAgdsbo9L4CrCRZBVhsktLFA6BSrVEX/HQVZekCBb3LmKMS6cZl5UuvgbU
QQQNnU8eyIPa9kd2CVQTVrKnnLhTyax7D3KigvbsjrrXZA15EZn5Z0t1Jf1KB5k=
=fTrj
-----END PGP SIGNATURE-----

--DIOMP1UsTsWJauNi--
