From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net] e1000e: keep vlan interfaces functional after
 rxvlan off
Date: Wed, 18 May 2016 14:39:59 -0700
Message-ID: <1463607599.2713.70.camel@intel.com>
References: <1463511831-13684-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tJ5k+bC+fPXu7NuikaZw"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>, linux-kernel@vger.kernel.org,
	Raanan Avargil <raanan.avargil@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463511831-13684-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-tJ5k+bC+fPXu7NuikaZw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-05-17 at 15:03 -0400, Jarod Wilson wrote:
> I've got a bug report about an e1000e interface, where a vlan interface
> is
> set up on top of it:
>=20
> $ ip link add link ens1f0 name ens1f0.99 type vlan id 99
> $ ip link set ens1f0 up
> $ ip link set ens1f0.99 up
> $ ip addr add 192.168.99.92 dev ens1f0.99
>=20
> At this point, I can ping another host on vlan 99, ip 192.168.99.91.
> However, if I do the following:
>=20
> $ ethtool -K ens1f0 rxvlan off
>=20
> Then no traffic passes on ens1f0.99. It comes back if I toggle rxvlan on
> again. I'm not sure if this is actually intended behavior, or if there's
> a
> lack of software vlan stripping fallback, or what, but things continue to
> work if I simply don't call e1000e_vlan_strip_disable() if there are
> active vlans (plagiarizing a function from the e1000 driver here) on the
> interface.
>=20
> Also slipped a related-ish fix to the kerneldoc text for
> e1000e_vlan_strip_disable here...
>=20
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: intel-wired-lan@lists.osuosl.org
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
> =C2=A0drivers/net/ethernet/intel/e1000e/netdev.c | 15 +++++++++++++--
> =C2=A01 file changed, 13 insertions(+), 2 deletions(-)

Raanan, please review this patch. =C2=A0Even though it is an RFC I will be
adding it to my queue for testing.
http://patchwork.ozlabs.org/patch/623238/
--=-tJ5k+bC+fPXu7NuikaZw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXPOEwAAoJEOVv75VaS+3OFKAQAJ1nSQ9EUI9U7fFpvJWD6i6z
zjsI8d2EGbYOZw6iP0ccPgYrwP1UCxfdNHW2+tZqYOa5Mcq7jeCckJprqcAiftpm
t5VQQv+B6xXoNX4E1F57fInOsclkbq4x2+6cRQAESIr2JgP7S9xLo60mT70BjTJr
Qf42FP2oJXFjTkv/BouW4aAOG+R6xoIKq6s+pIfUeWPQeHxtjHJwLX1pLbbOj09s
jAUvXX6EM+Fwgmc6cLVDig0nWZBEZdieyMnlFeTNTPPtvt1QPwxpOX+efqRAjxEZ
0ozHPlhqzL8aYuml/CL7bv4kPhloKrfgjD1luJlNCHA5MBQR6bt3+QcT+aCsOa4p
OOunIYTsy0pGCgHVt0B4JJab1WbeogojEJzSZcGd4k/Pi6YQlUmJrhhbCTs+GMLG
v1sRRhJ624sU+G57NRokdSufiUmpI507C36/YCeZ+PsYrUImTtBgrxRRUny7en5j
Vgk6I1J5m/oIU7PzZ0tgk2kiJ2rQkJJ53P5k6j6x9ha7kqDZXnYfOlFtO2rmBic4
S7Mdrh+LMUYvUqRnaCj4YQII/yscfVbYOnDDtf/+pA3/H1lAvnFiuTH2iRgeGBr3
jcN+b2EYsc7d1tl3IHWeBPAOoNeqg8pUs4ZLW/4OKMMAC0pv/+fYNl+OD7TbKPPg
3HXaKECYCNQyfhIYEKxx
=g7yc
-----END PGP SIGNATURE-----

--=-tJ5k+bC+fPXu7NuikaZw--
