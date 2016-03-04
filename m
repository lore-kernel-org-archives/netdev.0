From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next] net: ixgbe: Fix cls_u32
 offload support for ports and fields with masks.
Date: Fri, 04 Mar 2016 14:10:13 -0800
Message-ID: <1457129413.2936.27.camel@intel.com>
References: <1457120869-3489-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qgavpq0R67zajG9ZNzso"
To: Sridhar Samudrala <sridhar.samudrala@intel.com>,
	intel-wired-lan@lists.osuosl.org, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:48491 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759071AbcCDWK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 17:10:27 -0500
In-Reply-To: <1457120869-3489-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qgavpq0R67zajG9ZNzso
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 11:47 -0800, Sridhar Samudrala wrote:
> Fix support for 16 bit source/dest port matches in ixgbe model.
> u32 uses a single 32-bit key value for both source and destination
> ports
> starting at offset 0. So replace the 2 functions with a single
> function
> that takes this key value/mask to program both source and dest ports.
>=20
> Remove the incorrect check for mask in ixgbe_configure_clsu32()
>=20
> Tested with the following filters:
>=20
> =C2=A0#tc qdisc add dev p4p1 ingress
> =C2=A0#tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0handle 800:0:1 u32 ht 800=
: \
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0match ip dst 11.0.0.1/24 =
match ip src 11.0.0.2/24 action drop
>=20
> =C2=A0#tc filter del dev p4p1 parent ffff: protocol ip prio 99 \
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0handle 800:0:1 u32
> =C2=A0#tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0handle 1: u32 divisor 1
> =C2=A0#tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0handle 800:0:10 u32 ht 80=
0: link 1: \
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0offset at 0 mask 0f00 shi=
ft 6 plus 0 eat match ip protocol 6
> ff
> =C2=A0#tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0handle 1:0:10 u32 ht 1: \
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0match tcp src 1024 ffff m=
atch tcp dst 80 ffff action drop
>=20
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c=C2=A0 |=C2=A0 3 +--
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 17 ++++----------
> ---
> =C2=A02 files changed, 5 insertions(+), 15 deletions(-)

Is this v2? =C2=A0If not, why are you re-sending a patch that is already in
my queue? =C2=A0If so, where is the changelog so we know what changed in
this updated v2 of the patch?
--=-qgavpq0R67zajG9ZNzso
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW2gfFAAoJEOVv75VaS+3OtWAP/jnucf6W6ST6LK87tVDuEywn
r9cexWFpBLS3DKRO1hTVu1iG2zDnDxeNp+oNCvZE+1+PM9fKhe+kxHwreAa7+EBA
IVjhihCtX9vucV1gf+YSZ9CzvO0lbsCCNuE6Ckt/3Cxi/HyAoiRpE7FRuBng6qW+
Qyn3YKnhOdu9VunFWUHc9qU58uC/ZwucV+zDCMlHqO6qLXU5ddCRdHa5dVkOB5Wx
KgXQR+CDPYrMiugZ8hmWy+K78LVN3BISrB0fBJ/w3wapAj+ayE5N7r1cdId/0Hz+
rPk5m205EDsRHOMnuTCMAYwL2f1Q8qsqJBEbuVJank2+Ylg77thMGbTSRO95Vvf4
s6TxiNValnZapgPgQ+CB2E9xEqkMPLz+dousm1SgzPQQRzYp49tFyIX+hNRElXmk
OJIa6NQzKetCp7NvSv6v8AGRB6ajz1ritfG2q4tl9c7J3BdT6I5TpbohiU8jGmLu
Tuh9E1B2NWWIXD2Guh+80W6qZ0X32ulXdj3cNRCPqJGyBy7OLkuDP2cQ/dll/cv9
OqtJaU4jndqrZxPEH7JwOzKrAmn6wqdInNQpERtpVt+TRA7SEDnYzik7TIlh+WQa
YDoYClwApRggJkUipBAQRKiJ6mkPyi5H9vmzupEVImZNy/l6009v+vp3ggYh5O26
em42vmxm/KLVCiasExCn
=k1jT
-----END PGP SIGNATURE-----

--=-qgavpq0R67zajG9ZNzso--
