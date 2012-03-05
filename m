From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] pch_gbe: memory corruption calling
 pch_gbe_validate_option()
Date: Mon, 5 Mar 2012 09:33:49 +0300
Message-ID: <20120305063349.GE1003@mwanda>
References: <20120301071708.GB6959@elgon.mountain>
 <20120301.172402.1035366198258013912.davem@davemloft.net>
 <CAOD=uF5+DHqxBW9waP3CYrfrq_WiBjWsyoKkZCSq+GvOsoUpMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zBZpvCNcoXwafAjP"
Cc: David Miller <davem@davemloft.net>, masa-korg@dsn.okisemi.com,
	paul.gortmaker@windriver.com, jeffrey.t.kirsher@intel.com,
	mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: santosh prasad nayak <santoshprasadnayak@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:39321 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622Ab2CEGcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 01:32:46 -0500
Content-Disposition: inline
In-Reply-To: <CAOD=uF5+DHqxBW9waP3CYrfrq_WiBjWsyoKkZCSq+GvOsoUpMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zBZpvCNcoXwafAjP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 05, 2012 at 11:04:49AM +0530, santosh prasad nayak wrote:
> Dan,
>=20
>         Your fix may introduce new bug.
>=20
>          hw->phy.autoneg_advertised =3D tmp
>=20
>        Assigning signed integer to unsigned short  leads to bit truncatio=
n.

In this case it doesn't.  It's going to be 0x2f or less.  I
obviously checked this before I submitted the patch.

>        Is it safe for both Big-endian and little endian format ?

It's CPU endian in both cases.

>=20
>        AutoNeg is initialized with a Negative value (OPTION_UNSET)
>         Won't it create any issue with above assignment ?
>=20

Nope.  It gets set to 0x2f inside pch_gbe_validate_option().

>=20
> The simpler fix is to make "autoneg_advertised" signed integer.
>=20
> struct pch_gbe_phy_info {
>         u32 addr;
>         u32 id;
>         u32 revision;
>         u32 reset_delay_us;
>         u16 autoneg_advertised;     // =3D=3D> int autoneg_advertised
> };
>=20

The better fix would be to change pch_gbe_validate_option() so it
isn't so easy to call improperly.  I would have done that except
that probably we won't introduce many more callers, it seemed
like a lot of work and I don't have the hardware to test the
results.

regards,
dan carpenter


--zBZpvCNcoXwafAjP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPVF5MAAoJEOnZkXI/YHqRHkAP/1er54qzOGBcBN1LkEiPXaBW
6QgNlio5jBWqEeEpnid9Q/Kc4ClsUr7TqhRvaqxi7k1Wkp0wzSuAge92mSGAm05D
EWYPLy4+RXmCu4Y//dmjvCZ0yKEoAzR+i5M6LoOc+3kdTD9V9pNIpkEGkMXowQ/x
IbO5wgic1tKEpG3pnSDlBqEKZvjQCvAbCmbuWtobXC+rTNDSwac9SbxG4t41U6YG
a44HeAvMDk3vv+cWEj9KeQ4n/YJFtdyxMkAFCyf1u3wD3kEho39dpQDyjPU2QFWK
Tu2nWoDaaTvN67iSnxxlTTqCwCPeDIMyKoZzoLNPiMeWhUUQd0t6ET2Ymn+vxq92
LtnCA0pzUJMhXtHVvGFK5BV68aorNu37gpuIUNyaxuZdyYAes4Tf/1EOasFBLZhW
6mNBZkEMSNKnMCyQMqbGWmKpqJPh/ouI+JyQ1mJ/wFSSnjKPR/PQywpJ96y57rzy
m0TCIKDU9VJDhF9sPUWb9SBo5zYE0Ce+0bRSd0MK7tHM+4H0ZHK7MyGXFI95WOnN
PUuKjjEK9eyJfO7huE5U1miLDd1leKZTKVujHBV1rEj50ibsUF9Sib1KeDb5a8FQ
jk84Jts5Or928WJ7NZNjJnn2pPLY91zr6t6D/cG5QOUrpiMXPEaW5kKY1ST5KiLL
/A1wKqCOXDihVbG0xlJ4
=75+Y
-----END PGP SIGNATURE-----

--zBZpvCNcoXwafAjP--
