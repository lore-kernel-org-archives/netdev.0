From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Tue, 17 Dec 2013 17:56:09 -0800
Message-ID: <1387331769.2330.12.camel@jtkirshe-mobl>
References: <20131218124657.f573d9ae178ea37fa971456d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bpj1wp9CNtR2ivYx+FkM"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Anjali Singhai Jain <anjali.singhai@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131218124657.f573d9ae178ea37fa971456d@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bpj1wp9CNtR2ivYx+FkM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-12-18 at 12:46 +1100, Stephen Rothwell wrote:
> Hi all,
>=20
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/intel/i40e/i40e_main.c between commit 3c325ced6aef
> ("i40e: fix null dereference") from Linus' tree and commit bc7d338fbb3f
> ("i40e: reinit flow for the main VSI") from the net-next tree.
>=20
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
>=20

Your fix is fine, what I have in my tree is the following, so if you
want to modify your change so that the resultant code looks like this:

        struct rtnl_link_stats64 *vsi_stats =3D
i40e_get_vsi_stats_struct(vsi);
        int i;
 =20
        if (test_bit(__I40E_DOWN, &vsi->state))
               return stats;

        if (!vsi->tx_rings)
               return stats;
 =20
        rcu_read_lock();
        for (i =3D 0; i < vsi->num_queue_pairs; i++) {

--=-bpj1wp9CNtR2ivYx+FkM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSsQC5AAoJEOVv75VaS+3O7lQQAJjuUL7GLZrx9wgSzEeQ17Wr
B+TvpYVDBo0M7UPBNsmh235UgRaTbs7LWUjhEsTkskwYuaVpm9bH1wqfPu8/eSvi
qSWTvduJY3l5gUdc9eCUVoUvWVrx7dDYmizriQLMUVZCFOT5c9hyAdyiDja416Xm
iCC48vQOdYuqIz4E93T7H6oIPOAqWAbggW7D100wbAo4z+G7a4181u5iOHR4wzlZ
uxbMkkifyRzDYUuJ7q1QiGeZIC8Ng+16oMNi9+5//m1jnjC1NP2Knicbci9pp3KP
j3XxI7AJRHUfe2qnj3lY600RwRl38Wi2rlvRgvwo1pzmRbKLUKupxrYz+IP33LSr
i4TnTVk6ndRyR3qcJG7zt8KPiBQjIHV9Xj2RWgpBtzv+IAU141POONcCEo17Z/sU
GcxNo5U9jBegdBvJ05/YzmX1+R2RErvvmlM3tzKUF5yKJ9XxZ6vdbAdmqZ5lYHR1
NuplLUuTaRscrNcSfy1O1xwpQC+uCtCBDs6E8obVb4eZUj9m4XspvxVokhfUVPLR
UAUZeJN8gW04x1GfBkeT0VRUNFZKAn/Mxp74beCGTe4sCAJlr83Wh87WAkEwICB1
nepxDmrgCC/mGxKX31/4xjGNf1dMViEid5padJeX4kwskcNteYSiDEJyejYPPja6
t9Z42o3+n7sdsg/Jn/Ek
=Ho12
-----END PGP SIGNATURE-----

--=-bpj1wp9CNtR2ivYx+FkM--
