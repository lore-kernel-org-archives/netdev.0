From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH 09/21] batman-adv: slight optimization of addr compare
Date: Mon, 23 Dec 2013 09:46:11 +0100
Message-ID: <52B7F853.8050806@meshcoding.com>
References: <52B7C5C5.2050304@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="g5XcogJhD359ADB4e2ucbbDI75l6A1kmu"
To: Ding Tianhong <dingtianhong@huawei.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	"David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:7488 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831Ab3LWIrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 03:47:16 -0500
In-Reply-To: <52B7C5C5.2050304@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--g5XcogJhD359ADB4e2ucbbDI75l6A1kmu
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 23/12/13 06:10, Ding Tianhong wrote:

[...]

> --- a/net/batman-adv/originator.c
> +++ b/net/batman-adv/originator.c
> @@ -41,7 +41,7 @@ int batadv_compare_orig(const struct hlist_node *node=
, const void *data2)
>  	const void *data1 =3D container_of(node, struct batadv_orig_node,
>  					 hash_entry);
> =20
> -	return (memcmp(data1, data2, ETH_ALEN) =3D=3D 0 ? 1 : 0);
> +	return ether_addr_equal_unaligned(data1, data2) ? 1 : 0;

ether_addr_equal_unaligned() returns a bool value which is implicitly
converted to 1 or 0: there is no need for the ternary if anymore.


>  }
> =20
>  /**
> diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
> index 4add57d..5e66d4b 100644
> --- a/net/batman-adv/translation-table.c
> +++ b/net/batman-adv/translation-table.c
> @@ -51,7 +51,7 @@ static int batadv_compare_tt(const struct hlist_node =
*node, const void *data2)
>  	const void *data1 =3D container_of(node, struct batadv_tt_common_entr=
y,
>  					 hash_entry);
> =20
> -	return (memcmp(data1, data2, ETH_ALEN) =3D=3D 0 ? 1 : 0);
> +	return ether_addr_equal_unaligned(data1, data2) ? 1 : 0;

same here


Moreover, include linux/etherdevice.h in both files as explained in
point 1) of Documentation/SubmitChecklist

Thanks.



Cheers,

--=20
Antonio Quartulli


--g5XcogJhD359ADB4e2ucbbDI75l6A1kmu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSt/hYAAoJEEKTMo6mOh1VtSYP/Re+Vdh9ZAmAx9QhhKNjTnj8
zLXP8iyiCavjfyEGjgODWvB8vIo7nsit4QEq2ELM+vOiDpH04mFg35Bq7eRyIymb
SNER9N0i/9Gr0s5MUCf45Zs0nMKpuMHU0I/FPBK+89n3jU01kbXkUXOvqdvQK+Je
CZ8+C4+fxvpfBunUqq8NdXTEsaNxrEL+0BQht/4vDu3dn0z6O7gYIh8lD1jVm++Q
NVJtJt8xUi/E0W8+mcs0HkvdVwIv+XznRPV/imwNYL3ROdqkZe4WCtTLz5vvvpfK
WCzglCPAQNKtp3P1qP38+/D8UDv7QDEx5N3usUj09UTwM7uirh5fivqB2LwoT3BX
t7nuTEKZc6S9NR0BhYo0p6VPr0VwTawplkXuUvWvibUCECELYU/+78vJImKuLWZ3
P8xRqmPNLbDr8e+kzg2riQDgMY1jfsv6BqAx71X3DL4sng2DI1GkmvtngGbb6POd
KkeN4Wyit4FtuejfNmxAO995rhu9mlhs/9GtWnBMLHPA6vXSFX/HU4ycQqFkRdbf
GxqQI/gSXyjajwS3YEBOG1wz/ggZqS0xW30WLKpzZ/iUUVB8h60+TfhU/j8BWSu0
CE9tq8Z24e/hpb2/pvnhTx/PUrWdK0RZdIlGVur+yxiEUw+JD/eJmARPu0WI/X14
vEwBBP6zO6W0xudZXCN8
=of4y
-----END PGP SIGNATURE-----

--g5XcogJhD359ADB4e2ucbbDI75l6A1kmu--
