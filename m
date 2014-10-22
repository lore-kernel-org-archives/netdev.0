From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: don't reuse pages with pfmemalloc flag
Date: Wed, 22 Oct 2014 11:30:30 -0700
Message-ID: <1414002630.2179.0.camel@jtkirshe-mobl>
References: <1413985819-9553-1-git-send-email-klamm@yandex-team.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dWc/F43FGjap8lqEml6R"
Cc: jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, davem@davemloft.net, sassmann@kpanic.de,
	gregkh@linuxfoundation.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Roman Gushchin <klamm@yandex-team.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413985819-9553-1-git-send-email-klamm@yandex-team.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-dWc/F43FGjap8lqEml6R
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-22 at 17:50 +0400, Roman Gushchin wrote:
> Incoming packet is dropped silently by sk_filter(), if the skb was
> allocated from pfmemalloc reserves and the corresponding socket is
> not marked with the SOCK_MEMALLOC flag.
>=20
> Igb driver allocates pages for DMA with __skb_alloc_page(), which
> calls alloc_pages_node() with the __GFP_MEMALLOC flag. So, in case
> of OOM condition, igb can get pages with pfmemalloc flag set.
>=20
> If an incoming packet hits the pfmemalloc page and is large enough
> (small packets are copying into the memory, allocated with
> netdev_alloc_skb_ip_align(), so they are not affected), it will be
> dropped.
>=20
> This behavior is ok under high memory pressure, but the problem is
> that the igb driver reuses these mapped pages. So, packets are still
> dropping even if all memory issues are gone and there is a plenty
> of free memory.
>=20
> In my case, some TCP sessions hang on a small percentage (< 0.1%)
> of machines days after OOMs.
>=20
> Fix this by avoiding reuse of such pages.
>=20
> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)

Thanks Roman, I have added you patch to my queue.

--=-dWc/F43FGjap8lqEml6R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUR/fGAAoJEOVv75VaS+3OuV4P/RBaynj5QLMB3K9ZoxWZxs4+
oCHBE3IpWuzWwpveXT/yMdsFKQ/7i5S+2h1Tj/H78GacQP3nDJwflWotpzcFwC3q
ufnJhzIiFVE+FOsCvA3fca8uiGx6aONSIY3bP0M15w75BSKUUYFZcgRfo+YUsXUI
QcTR7nAzLyKO0H5epcb4D2rilytz7eWpjOUGOe3ZNfeh18ZuqEP+xsiBhBL1QNyv
TcVjVdzi9U9FQ6siUXHTuYXGjw7rGWrHyJ8qhvGEEgleBPR38xt+jN2hTdmYdSDX
CBzHviaYR2sz+IE6Bb0DDIe9+HZbVbceQuWTsfqkz5rbzuONr95jyuHdAMg2fdeN
qDzUUmPNlYwEic0Uf2YLDMbU988kAXInHE1S2XeG6dNjh+r3WgiXrz9fRfGKET1R
Mjer4/2Vxs9L1SY0ncbZvBc8EktL7aDyhWOuY/v4z63KlwhgyNiyb9ebUOIM23vY
w4d4PHk3mPlA7kqnqK3TG5DppEeoKlMFQBMIic5vgyqmHevyTg4R2NZewxfFpiwb
7ZTiH338CrXvrlmbLV/+mfm2F81E2CKlxdC/IG1MCdYyUcCT4KcGUuAwYcta/JT5
kskqfbR0PvjbcIhDf7TVIlxxy8alYQA5HIEHMLWltlx3aSocPK/PPXOuOTcpu0KQ
oGB0Eq5v7i1iCEIqDamB
=ZF2t
-----END PGP SIGNATURE-----

--=-dWc/F43FGjap8lqEml6R--
