From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race
Date: Tue, 05 Jan 2010 07:55:14 +0100
Message-ID: <4B42E252.1080405@gmail.com>
References: <OF7FCD6D97.5F7C3DD3-ON882576A2.00001FF7-882576A2.00009335@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Flavio Leitner <fbl@sysclose.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53677 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003Ab0AEGzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 01:55:23 -0500
In-Reply-To: <OF7FCD6D97.5F7C3DD3-ON882576A2.00001FF7-882576A2.00009335@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/01/2010 01:06, David Stevens a =E9crit :
> For readability, instead of:
>=20
>         ret =3D X;
>         if (condition)
>                 goto out;
>=20
> I prefer:
>=20
>         if (condition) {
>                 ret =3D X;
>                 goto out;
>         }
>=20
> which makes it clear that ret is for the return and not
> some random state change unrelated to the condition.
>=20

Linus argument for this common Linux coding style is that generated cod=
e is smaller

	mov	$-6,%eax
	cmp	condition
	je	out

versus
	cmp	condition
	jne	.ok
	mov	$-6,%eax
	jmp	out
=2Eok:

