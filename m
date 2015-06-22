From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 1/2] batman-adv: Avoid u32 overflow during gateway select
Date: Mon, 22 Jun 2015 14:53:12 +0200
Message-ID: <55880538.1050109@meshcoding.com>
References: <1434481584-1275-1-git-send-email-antonio@meshcoding.com> <1434481584-1275-2-git-send-email-antonio@meshcoding.com> <20150621.093713.572451264516042062.davem@davemloft.net> <1534492.Qn5WYoJSum@sven-edge>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="TX1QbHjKQqkHSMUQDb8nJDLKNtPn5Il7B"
Cc: Sven Eckelmann <sven@narfation.org>, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org, ruben@freifunk-nrw.de,
	ruben@vfn-nrw.de, mareklindner@neomailbox.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:39072 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933660AbbFVM4F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2015 08:56:05 -0400
In-Reply-To: <1534492.Qn5WYoJSum@sven-edge>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TX1QbHjKQqkHSMUQDb8nJDLKNtPn5Il7B
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 21/06/15 20:27, Sven Eckelmann wrote:
> On Sunday 21 June 2015 09:37:13 David Miller wrote:
>> From: Antonio Quartulli <antonio@meshcoding.com>
>> Date: Tue, 16 Jun 2015 21:06:23 +0200
>>
>>> @@ -133,7 +133,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv
>>> *bat_priv)>=20
>>>  	struct batadv_neigh_node *router;
>>>  	struct batadv_neigh_ifinfo *router_ifinfo;
>>>  	struct batadv_gw_node *gw_node, *curr_gw =3D NULL;
>>>
>>> -	uint32_t max_gw_factor =3D 0, tmp_gw_factor =3D 0;
>>> +	uint64_t max_gw_factor =3D 0, tmp_gw_factor =3D 0;
>>>
>>>  	uint32_t gw_divisor;
>>
>> Divides are performed using these variables, so if you make
>> them 64-bit the build will fail.  You have to use one of the
>> routines in include/linux/math64.h in this situation, but
>> realize that this operation is now going to be quite expensive.
>=20
> Just a minor comment: The division is currently "max_gw_factor >> 18" w=
hich=20
> the compiler also outputs as such (shrd + shr on i586). This is the rea=
son why=20
> it currently also works on architectures without a native 64 bit div.


Thanks for the comment David and Sven.


David you can drop this pull request.
I'll send a new one later with a modified patch that explicitly
introduces the shift.



Thanks!

--=20
Antonio Quartulli


--TX1QbHjKQqkHSMUQDb8nJDLKNtPn5Il7B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJViAU8AAoJEOb/4TMchkvfk5QQAJqhTf9FPJQEe899Ru1uhxlF
EhkJYGx/0N1iKkwfwaCkuYUEFGo0PrILoUgONZudso9atckueMnoq4IWt/+txU9A
nVYm14DhwMrjuLT2SwUcY4U+zNJDYqY9zJuNHSeBGjMbERXq6o3RhMqIi87YMQMS
qDhrHcf+Gjru8/D73drjMkd8soUlaL/YE2POUB+WKBP8yeKzqavd2xlipCVSA0C+
Yq5mZAut1mM6eIaUhOeuvErNR5wV5m1dCvRj9cabbynQbgorujmEsf92iCwqz/kT
MtN4P0fPZTrKWkxKAqPh/gntf2x51bdUOo75yM2gxVmiOqAyuix1Ky7zfuL18qYZ
fj3gAcQRlIX16OneR6jlRA6RXM+4eKTiYxeAjoNb0G7lQvHYnhrDdZ5sUqEyQGiq
L3RDAbhAgJIlOqj1RbzB/l4i+JyugWE8/0TEiCEjVJXLqMhKv7yiZUL+wWucQ6eU
a1wlLA03SC3xx06Xn8omcOcQ3FpCwOqXqL8SehhEtWaUhm6CRPO1wes2mdT2dbqg
Ys8Fa6PUti+YYuN15yUG0fdx+35EzTLUFd9SzK9vCZnuYbEHXrHVDC8OFy3vXk83
HtLkXJ7k6HW+goRFamoN/7ZgyrcF2iaSkoInfC7I6SYh+rx/PS51vxeTvtYB5h/o
zi4eQEclU+BkfFzsXriH
=tjLa
-----END PGP SIGNATURE-----

--TX1QbHjKQqkHSMUQDb8nJDLKNtPn5Il7B--
