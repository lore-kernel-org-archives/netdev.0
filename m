From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Sat, 01 Nov 2014 16:05:50 -0300
Message-ID: <54552F0E.70407@free-electrons.com>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>	 <1414862766.31792.7.camel@edumazet-glaptop2.roam.corp.google.com> <1414863453.31792.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="uc51Ai28471qP4cHBgelf9oGSVxMUw5B3"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:47249 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758796AbaKATHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 15:07:32 -0400
In-Reply-To: <1414863453.31792.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uc51Ai28471qP4cHBgelf9oGSVxMUw5B3
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/01/2014 02:37 PM, Eric Dumazet wrote:
> On Sat, 2014-11-01 at 10:26 -0700, Eric Dumazet wrote:
>> On Sat, 2014-11-01 at 12:30 -0300, Ezequiel Garcia wrote:
>>> Several users ([1], [2]) have been reporting data corruption with TSO=
 on
>>> Kirkwood platforms (i.e. using the mv643xx_eth driver).
>>>
>>> Until we manage to find what's causing this, this simple patch will m=
ake
>>> the TSO path disabled by default. This patch should be queued for sta=
ble,
>>> fixing the TSO feature introduced in v3.16.
>>>
>>> The corruption itself is very easy to reproduce: checking md5sum on a=
 mounted
>>> NFS directory gives a different result each time. Same tests using th=
e mvneta
>>> driver (Armada 370/38x/XP SoC) pass with no issues.
>>>
>>> Frankly, I'm a bit puzzled about this, and so any ideas or debugging =
hints
>>> are well received.
>>
>> lack of barriers maybe ?
>>

Yup, that was my initial thought as well...

>> It seems you might need to populate all TX descriptors but delay the
>> first, like doing the populate in descending order.
>>
>> If you take a look at txq_submit_skb(), you'll see the final
>> desc->cmd_sts =3D cmd_sts (line 959) is done _after_ frags were cooked=
 by
>> txq_submit_frag_skb()
>>
>> You should kick the nick only when all TX descriptors are ready and
>> committed to memory.
>>
>=20
> Untested patch would be :
>=20

Yeah, it makes sense. I'm still seeing the corruption after applying
your patch.

However, maybe we are onto something. I'll see about taking a closer
look and give this some more thought.

Thanks for the hint!
--=20
Ezequiel Garc=C3=ADa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com


--uc51Ai28471qP4cHBgelf9oGSVxMUw5B3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUVS8UAAoJEIOKbhOEIHKiKcsQAJfKj+Q3gz4/GPO06X88rh4c
RJzcClTF8dossYptEvxGmB5ki2wlqgrf9LUug144XjL+68aymiIKKFQCFHAB76ec
DkD0JFflz2CfgF6pZtCuhTuOgWLGfKv8UwbOG07nEz6Q2BimbN0lhLX7dpQvPhst
9XEDEuP+h1rwLRunrobYOfFdQS3TBkd6hry/plG5cw12p+uEwEbAWzMbCasBwwt2
oxaD8+upgnnNXPuaKRlMsQowbAjxx5wM95suBbXZ4mdit56n8pwZnFbyjh1ubA3x
ESxVV+0divr+CmPaLdAAqFU4c4h5Gk1lu12neAKmeNTvgPPn+BMMKw9cqbzFk8U6
ajI1FWXfQ/msU4S+kqEXvWA3iuXeNTudAyLJ2khw/4W2gsaZ8gUNOcSXf+gfSgEr
eDGQc7o0V8lnLNm5Gyv/PH+zLpP5MVBU4GjzG0CXXNlCbyopDJntUbAMWi1P2Ntu
QTKz9HJkN1Q5IA6oBqBnoTSVGHfzNKmnX56cQ4toGY8Z52OEkdajhZ3Gu3n/T3wr
stgSx15DMcTh4DAyycY/kX2evMJCYTIYiIRBNQ6RiU21RlerSElBZ4oqkjBiLH9E
88pdstfknu2kNSlKwOP4DQNJyxMvikScmdvDfNMQHa671sSB0HGAJTSHF/ZwJw6V
yfMz3UNtoQWz7vi9e+ki
=4xRw
-----END PGP SIGNATURE-----

--uc51Ai28471qP4cHBgelf9oGSVxMUw5B3--
