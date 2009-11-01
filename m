From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] r8169: partial support and phy init for the 8168d
Date: Sun, 01 Nov 2009 16:24:43 +0000
Message-ID: <1257092683.3136.325.camel@localhost>
References: <20091007224420.GA20170@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-u8JoqQIonLHjsdhWKauZ"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39435 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752790AbZKAQYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2009 11:24:47 -0500
In-Reply-To: <20091007224420.GA20170@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-u8JoqQIonLHjsdhWKauZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-10-08 at 00:44 +0200, Francois Romieu wrote:
> Extracted from Realtek's 8.012.00 r8168 driver.

There is a problem with this change:

[...]
> static void rtl8168d_1_hw_phy_config(void __iomem *ioaddr)
> {
[...]
> +	static struct phy_reg phy_reg_init_2[] =3D {
> +		{ 0x1f, 0x0005 },
> +		{ 0x05, 0xffc2 },
> +		{ 0x1f, 0x0005 },

I interpret the following sequence of register writes as:

> +		{ 0x05, 0x8000 },
> +		{ 0x06, 0xf8f9 },
> +		{ 0x06, 0xfaef },
> +		{ 0x06, 0x59ee },
[...]

Write memory sequentially from 0x8000,

> +		{ 0x05, 0x83d4 },
> +		{ 0x06, 0x8000 },
> +		{ 0x05, 0x83d8 },
> +		{ 0x06, 0x8051 },
[...]

Change two vectors to point into what was just written.=20

I believe this is patching machine code in the PHY.  And we do not have
source for that code, so it cannot possibly be distributed under GPL.

Please replace this with use of request_firmware() and submit the blob
to linux-firmware.git instead.

The same goes for phy_reg_init_1 in rtl8168d_2_hw_phy_config().

Ben.

--=20
Ben Hutchings
The generation of random numbers is too important to be left to chance.
                                                            - Robert Coveyo=
u

--=-u8JoqQIonLHjsdhWKauZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASu22Rue/yOyVhhEJAQJo+BAAiDkA+2vGXWN8fI10q4xBTIwCOFsi88/W
Eu8en9eaf5s4/jOCjF80Obz2KhLj/+e5TyZjVBrMYGyZaXGb/QEpbEsLdXmzdwW9
guNjntqdsuYgaGQOBWk8Ikt8VRD25UgksERKHbVf8uyCb9avPeSszxkt8UnnseXz
HbBd8sYeyoFKW4VGVVXQ6i3bKb7uWAfZFiV1FOBFD0hsDk9yK2TMPahi6zfpJvPz
2Es0WhW9Q/UmDc5/1X7/4If1ZlF7SC159jLy+spog+bcIQS+LtDks+5jHY73HIAM
MOPFPPvj/0TF2DLSPyQsSw5EBnulRaiI8rVSEhKuz0FAljVF4Gc7B8wi+EyJb7bA
ynfLPC9syZlYXDjYHi5nHAH0qMeCTEwtPd2+SJAEKERaq5SecT7+3P8iKWH//xi7
yhwg+lzTA9NRmowr8nhrJr27YL6kay5a9uDciE8hwPMjlCvi0TCJ73JANbYusgJ1
c+3N5k80i3gl0gP3+Ntt3qR+bXqvyI/vKdTBINmlqsKOL7ZXW7/Hsf9Go1KeVphl
ZNsEV4/VkFrAQKs3wzm6wb9v7mF93ojyQtg9tewQzTKss0j1U9ubalEgloOUNzfF
hKM+P1ZJfqw1shUNe8D66IM4CNBUeLRB6XSeymYj8rrd+pCxc/I3esAJsfxtQahZ
+dstOzaQNOg=
=9BR4
-----END PGP SIGNATURE-----

--=-u8JoqQIonLHjsdhWKauZ--
