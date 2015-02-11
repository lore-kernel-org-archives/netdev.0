From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 10 Feb 2015 20:51:33 -0800
Message-ID: <1423630293.27854.65.camel@jtkirshe-mobl>
References: <20150210220215.5f87a13c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-sGfNBIEU6RqhAvr6oSVp"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150210220215.5f87a13c@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-sGfNBIEU6RqhAvr6oSVp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-02-10 at 22:02 +1100, Stephen Rothwell wrote:
> Hi all,
>=20
> After merging the net-next tree, today's linux-next build (i386
> allmodconfig and a few others) failed like this:
>=20
> drivers/net/ethernet/intel/i40e/i40e_txrx.c: In function
> 'i40e_setup_rx_descriptors':
> drivers/net/ethernet/intel/i40e/i40e_txrx.c:1101:3: error:
> incompatible type for argument 1 of '__seqcount_init'
> include/linux/seqlock.h:53:20: note: expected 'struct seqcount_t *'
> but argument is of type 'seqcount_t'
>=20
> Caused by commit 638702bd59a3 ("i40e/i40evf: Add call to
> u64_stats_init
> to init").
>=20
> Discovered after the release, so no fix done.
>=20
> The indentation of the lines added by that patch is also a bit
> strange.

Yeah, this was fixed with the follow on patch:

commit c07a213db1437a8fd40c328e6a2c426723caec65
Author: Carolyn Wyborny <carolyn.wyborny@intel.com>
Date:   Tue Feb 10 07:33:15 2015 +0000

    i40e: Fix for stats init function call in Rx setup
   =20
    This patch fixes indentation issue and error found in argument
    reported by static analysis.  Without this patch, sparse and other
    static analysis errors will be found.
   =20
    Reported-by: Fengguang Wu <fengguang.wu@intel.com>
    Reported-by: Julia Lawall <julia.lawall@lip6.fr>
    Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-sGfNBIEU6RqhAvr6oSVp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU2t/VAAoJEOVv75VaS+3OwpAP/AiL8DGfrGnO7y9rrlliDe12
LYuS4Qrindu2IE8+jHvM8OJXDDqpaQd8VeaXUWM4DtTnLA55zQO/ZUtP98UgaZN0
WFkZTwQJyk7qj/MWcQqGRYGsT62hmDW9+Lv6uq778qVPHjFEtdbynN6R5545IAKZ
qoa/URk6kJkPT5M4FMPTa7gM2U/GXwDQWkd1zeXy5Fr/+L26wGjpBKz3H0nFIXFO
rn+m54s1w0Y3AsziM6npcBOvDDUeBVT/lE9F3Oiy4QUah73P4vE6rX6wttOZz1/r
Ish2aeABQV42/H3+RlYorMebP8NG2BDF9B8b12v/R4no65l+fIc4EcTDktvwaEoq
BC+Y/UY2xF18w71XKREl8bRbWuauDLgRBAkNP8gKEcDmeMT1vIBc0EFUX64D62vI
NaC0lrf4FRvf7vxcQphlJZeyZMvMLu22SQg+YFIWt9UrmrU9ooXbpYn72Vm6NQdq
1x3oOusmbvN+nyawItrDe3H/s5k8VqmNgJ+ltfB11Nb/+DIQadIYUF1FxVkdHcMu
KeTsnMoDX4H0UOYrt7lGbXLTLA/VUQopkDFEJlt9ou44kGqgWc/tkzxzbnbLaJKS
+dwTsM7nVQJ8QNlcNy+UtqqDUf2unlhQOd1derbrwusU/fJCqakkaDE+pveAMylg
IwEKKb4BQlxJoNXGAnOM
=G++5
-----END PGP SIGNATURE-----

--=-sGfNBIEU6RqhAvr6oSVp--
