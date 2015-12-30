From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH 3/3] ixgbe: synchronize the link_speed and link_up of a
 slave interface
Date: Wed, 30 Dec 2015 19:02:54 +0000
Message-ID: <7EED4F91-2DE5-407F-BA6A-681ED57650E4@intel.com>
References: <53C6554C-8692-4EF3-BF5D-7217D2C9FDA0@intel.com>
 <1451466995-19015-1-git-send-email-zyjzyj2000@gmail.com>
 <1451466995-19015-4-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_83F9CC9A-D97C-4641-A12F-B7BF4026D167";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Viswanathan, Ven (Wind River)" <venkat.viswanathan@windriver.com>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>,
	"Bourg, Vincent (Wind River)" <vincent.bourg@windriver.com>
To: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23914 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbbL3TC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 14:02:56 -0500
In-Reply-To: <1451466995-19015-4-git-send-email-zyjzyj2000@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_83F9CC9A-D97C-4641-A12F-B7BF4026D167
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

zyjzyj2000@gmail.com wrote:

> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>=20
> According to the suggestion from Rustad, Mark D, this behavior perhaps
> is more related to the copper phy. But to make fiber phy more robust,
> to all the interfaces as a slave interface, the link_speed and link_up
> is synchronized.
>=20
> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
> ---
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    8 +++++---
> 1 file changed, 5 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c =
b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 1bb6056..ce47639 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -6441,10 +6441,12 @@ static void ixgbe_watchdog_link_is_up(struct =
ixgbe_adapter *adapter)
> 	 * a bonding driver in 802.3ad mode. When X540 NIC acts as an
> 	 * independent interface, it is not necessary to synchronize =
link_up
> 	 * and link_speed.
> -	 * In the end, not continue if (X540 NIC && SLAVE && link_speed =
UNKNOWN)
> +	 * According to the suggestion from Rustad, Mark D, this =
behavior
> +	 * perhaps is related to the copper phy. To make fiber phy more =
robust,
> +	 * To all the interfaces as a slave, the link_speed is checked.
> +	 * In the end, not continue if (SLAVE && link_speed UNKNOWN)

There is no need to make reference to my suggestion in the comment, =
especially since that is in the commit message. Please simplify your =
comment above to be something like:
	 * For all slave interfaces, wait for the link_speed to be =
known.

> 	 */
> -	if ((hw->mac.type =3D=3D ixgbe_mac_X540) &&
> -	    (netdev->flags & IFF_SLAVE))
> +	if (netdev->flags & IFF_SLAVE)
> 		if (link_speed =3D=3D IXGBE_LINK_SPEED_UNKNOWN)
> 			return;

The above would be better as:
	if ((netdev->flags & IFF_SLAVE) &&
	    link_speed =3D=3D IXGBE_LINK_SPEED_UNKNOWN)
		return;

Please do not send a series of patches - it just adds needless confusion =
and is a bisect hazard. Just send a single patch with the desired change =
as a V5.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_83F9CC9A-D97C-4641-A12F-B7BF4026D167
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWhCpeAAoJEDwO/+eO4+5uiNoP/R42mXbUsXChsGHXtw6ddWzv
SJEvQYfrL4qIANh/UyfMSnbmRQYZYCAWJeG+BmkQ41kBT4n5TAkjjQPk+1d2Y0+m
JHvBAlyMYrfTJtj0IZhCZurEe5FwSY3zzZ9h9v6J5Rl5k+ntPaStNxbyQ7s7NJid
j42ZzO+1VCQbuXTGqbLscdP9z8d8V/+42gOvEir03TKitDp5R2kZqEffyN2ES9+L
oncSgje75Mx1wc8lb+2l+rli9zLJN1miZTztaI/4847vszt+6prmlVThZ3ryK9Yw
Ff2tHvsssdOYz9LrMbHF/ib94CA9youih64T1o1Ic7GogxmP7wW9hOpArqLqog/B
7n+qutBxlG8rr/TUijX2X2OEywgLR3C5XxeDcfDAKz/EFzpnPRa5mOWPbE87dTDp
I9ThmIpXLiJFVbgJXfIqbTf4fxNWCRaxa/XdXDFrGQ7/6uQZavtCaYdfFAOJl6t9
MBovOalXHoiUJCCOogGS5mNwe79q1ur7RbDKhc297LuXhu/Hy0PzXEFriDx2rj9P
dnQb3GiuFBQVOGjdxc+lBzGjxMgnAyC81fJsqwopjxutxRBzlsi2cuD7zm5WI8cH
QOOHfmeNYezM6Add6X7XVAn1CHTtNNukQy4fYQIBDxvreMd8knUpDpG52hqcuvSc
TsmlabuROzG+Qk1gBXLD
=AdcL
-----END PGP SIGNATURE-----

--Apple-Mail=_83F9CC9A-D97C-4641-A12F-B7BF4026D167--
