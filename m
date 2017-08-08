From: Christian Langrock <christian.langrock@secunet.com>
Subject: Re: [PATCH] ip/link_vti6.c: Fix local/remote any handling
Date: Tue, 8 Aug 2017 09:53:34 +0200
Message-ID: <1f9cb1da-11cf-6b24-1fd9-c47f1ae03b21@secunet.com>
References: <4608c5ed-6b73-4bc2-f193-66e5129d855e@secunet.com>
 <20170807081225.7cd10477@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature";
        boundary="Bd31xTb1OG5ELawdwNfrTKSS55Iaolf9u"
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34656 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750818AbdHHHxl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 03:53:41 -0400
In-Reply-To: <20170807081225.7cd10477@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Bd31xTb1OG5ELawdwNfrTKSS55Iaolf9u
Content-Type: multipart/mixed; boundary="ceVpOAb7fPhaDtAsJqNA8b7IVxjwvcwxg";
 protected-headers="v1"
From: Christian Langrock <christian.langrock@secunet.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Cc: netdev@vger.kernel.org
Message-ID: <1f9cb1da-11cf-6b24-1fd9-c47f1ae03b21@secunet.com>
Subject: Re: [PATCH] ip/link_vti6.c: Fix local/remote any handling
References: <4608c5ed-6b73-4bc2-f193-66e5129d855e@secunet.com>
 <20170807081225.7cd10477@xeon-e3>
In-Reply-To: <20170807081225.7cd10477@xeon-e3>

--ceVpOAb7fPhaDtAsJqNA8b7IVxjwvcwxg
Content-Type: multipart/mixed;
 boundary="------------51745260D4320AC54A9C624D"
Content-Language: de-DE

This is a multi-part message in MIME format.
--------------51745260D4320AC54A9C624D
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

This seems to be the better solution, at least because i missed the case
where the function is called to alter a VTI.


BR,

Christian


Am 07.08.2017 um 17:12 schrieb Stephen Hemminger:
> On Mon, 7 Aug 2017 08:41:23 +0200
> Christian Langrock <christian.langrock@secunet.com> wrote:
>
>> According to the IPv4 behavior of 'ip' it should be possible to omit t=
he
>> arguments for local and remote address.
>> Without this patch omitting these parameters would lead to
>> uninitialized memory being interpreted as IPv6 addresses.
>>
>> Signed-off-by: Christian Langrock <christian.langrock@secunet.com>
> I don't like extra flag values.  Why not just:
>
> diff --git a/ip/link_vti6.c b/ip/link_vti6.c
> index be4e33cee606..6ea1fc2306ce 100644
> --- a/ip/link_vti6.c
> +++ b/ip/link_vti6.c
> @@ -59,8 +59,8 @@ static int vti6_parse_opt(struct link_util *lu, int a=
rgc, char **argv,
>  	struct rtattr *tb[IFLA_MAX + 1];
>  	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
>  	struct rtattr *vtiinfo[IFLA_VTI_MAX + 1];
> -	struct in6_addr saddr;
> -	struct in6_addr daddr;
> +	struct in6_addr saddr =3D IN6ADDR_ANY_INIT;
> +	struct in6_addr daddr =3D IN6ADDR_ANY_INIT;
>  	unsigned int ikey =3D 0;
>  	unsigned int okey =3D 0;
>  	unsigned int link =3D 0;
> @@ -195,8 +195,11 @@ get_failed:
> =20
>  	addattr32(n, 1024, IFLA_VTI_IKEY, ikey);
>  	addattr32(n, 1024, IFLA_VTI_OKEY, okey);
> -	addattr_l(n, 1024, IFLA_VTI_LOCAL, &saddr, sizeof(saddr));
> -	addattr_l(n, 1024, IFLA_VTI_REMOTE, &daddr, sizeof(daddr));
> +
> +	if (memcmp(&saddr, &in6addr_any, sizeof(in6addr_any)))
> +	    addattr_l(n, 1024, IFLA_VTI_LOCAL, &saddr, sizeof(saddr));
> +	if (memcmp(&daddr, &in6addr_any, sizeof(in6addr_any)))
> +	    addattr_l(n, 1024, IFLA_VTI_REMOTE, &daddr, sizeof(daddr));
>  	addattr32(n, 1024, IFLA_VTI_FWMARK, fwmark);
>  	if (link)
>  		addattr32(n, 1024, IFLA_VTI_LINK, link);


--------------51745260D4320AC54A9C624D
Content-Type: application/pgp-keys;
 name="0x82EB6B5E.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0x82EB6B5E.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

mQENBFee7jkBCACkeMIuzZu/KBA1q3kKGr7d9iiZGF5IpJnIE9dMiK3uaz7uM26V
STJVp6jdGuSGGGmb81OSLEcIEIsYKXvjblAKUX1A74t3WMRcky3MwJbmN6AkN8Ql
P45mDddtPRf1ElB2S32i9OrEkvw8xcvHYPwbaHenXic4/8fHWEh+vtd/5/5TDTIU
/ag9tQfPea13ixXN0PuccMubFeUMpwFCg324+Z19iGvfDWWZmQQGlBjc3Q6z0hXO
b/deWL/+lPS4t+tTgpmmZO4XkIs+18KqxCVukCbnqV0y+04sj3G1GQ/DlGvZHxwy
wBceAL7BvmdeXQKAS0KRL5zrghIBCgnUyutDABEBAAG0M0NocmlzdGlhbiBMYW5n
cm9jayA8Y2hyaXN0aWFuLmxhbmdyb2NrQHNlY3VuZXQuY29tPokBNwQTAQgAIQUC
V57uOQIbAwULCQgHAgYVCAkKCwIEFgIDAQIeAQIXgAAKCRCjeMdfgutrXu3kCACI
Bx6UHReBtBciNUPkP3fRaGeSOADIrql72VKD9faLAHTt6w8kvyzb8Ctpa77jswJt
21c349mF3maPlpNtpswqH27bTlXYhNcXxcmHPCbNtN3yGUy0UuIJfBMZc8PLqiqY
oY5GKD3uimeVbDYjgNhebO2f1cUvwY2wTwX6b0tgKVK0xYYTDpXI1/2MVGsjXqak
7PQoqVq0sDu0gIAAi1QO0Fbb6jIaHj6CEM2hpBTBk8qbkPs/MqYGdLl4oXvkWTLd
uQjm6dMtjxvIt6WJWZQbLjTeQIfc21luNQKDmfT623pVTPPMMAciWfpdw63FblfG
cfBnAKCJ8JBj0z9T6/PmuQENBFee7jkBCADS7amJPbY2dWpeGtE+I9yLL53lSriP
4L6rI9UoEwNM1OkjnB7wFnH8dm8N68K2OJogkHwoX2OnzGhxJ28NHRuAh++3hIYY
+gU4HMLaX3onDK1oqAdYczhJ7f6UCPbYaghkzJ6Vg/FEWpA8u5vG/BX4y+F3/Y98
l6mzAX5wLmTapRwdfuRCXRA6jlIHIOwP3NPKK4Pz2E7witsimV1ucN4uXFiZ36CU
PAiXXlER9iPZnQUSyCobqJOJKm4C7wUNQ1negCXDBd3KjSyzTIafw/oYG4RrWGul
iI2ig/qTUC8cZdAJTMBjUJR6ugJazMB1Rg17p2GRD0AzUOV2qdqYFqQFABEBAAGJ
AR8EGAEIAAkFAlee7jkCGwwACgkQo3jHX4Lra17vtQgAg2g0JEXVTGT36BDJgVjI
UY1evnm1fWwTPpcokP/8/aO2ubmlxtWQ2hV5OPfL5nDday2S4Nq5j3kqQq+rvUrO
RVmvT4WxYZM1fr2nibuzaUbsJtxphNpjahrsEcLLTzBW4CbHTaL4YTT+ZD/GDeHo
xAh9JfMkdMBXHyWTuw+QSP0pp7WvNsDosukKFyQ0rve9PH2dry6A0oLP7UxtAzEE
RV2Se0BueZPQuVnU6Cvj3ZStK28JDhMjxIPkZPE5kCV8QNF8OsiwymA3aoPKe5Bw
0lOcjuuJkxRa5bazyuubX9pIIgTeGsecgpSgpfA9jsEHKFqoLuxUA+77VQ5hSydV
aQ=3D=3D
=3DO6Ea
-----END PGP PUBLIC KEY BLOCK-----

--------------51745260D4320AC54A9C624D--

--ceVpOAb7fPhaDtAsJqNA8b7IVxjwvcwxg--

--Bd31xTb1OG5ELawdwNfrTKSS55Iaolf9u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJZiW3+AAoJEKN4x1+C62teGjIH+wS29gsALpFedTNz9TOkv4SI
tiN4LkQ0MwgnTVkYVAxAE8TMhiwskOxhVWlIcRaOQGFpeR0UcZo6dR2/XGTq+hkd
L7Jy/rKUiS4nh4PyMumzpf8I0ZTnRkeFdQvZ6ImYFmJBncK14rfCb0KI3Nu4Avir
a8FJT2lSiZpLnzXFMzM7sGESsHuC61+CXGI8g1lNMIW2Pyow1D/m574L8aZ+621S
37Ov1aZQJmX9axlawGn/xNnqc3YG/OdVApwTo5OWCatwNK2dOkjLaigIbux5Wax9
Wal5s0G1USj1hCc3Ot++Rs6TJEkk6k4xTTahN4fiYz63sn1Sn6r/IUOKZnFdn10=
=0wzS
-----END PGP SIGNATURE-----

--Bd31xTb1OG5ELawdwNfrTKSS55Iaolf9u--
