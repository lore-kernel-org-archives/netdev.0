From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] [02/10] pasemi_mac: Stop using the pci config space
 accessors for register read/writes
Date: Thu, 23 Aug 2007 10:31:03 +1000
Message-ID: <20070823103103.a1815a07.sfr@canb.auug.org.au>
References: <20070817205413.548020000@lixom.net>
	<20070822141248.GC16830@lixom.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__23_Aug_2007_10_31_03_+1000_N5WdhekWD3pD01YF"
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:39402 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbXHWAbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 20:31:11 -0400
In-Reply-To: <20070822141248.GC16830@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__23_Aug_2007_10_31_03_+1000_N5WdhekWD3pD01YF
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Olof,

On Wed, 22 Aug 2007 09:12:48 -0500 Olof Johansson <olof@lixom.net> wrote:
>
> -static unsigned int read_iob_reg(struct pasemi_mac *mac, unsigned int re=
g)
> +static inline unsigned int read_iob_reg(struct pasemi_mac *mac, unsigned=
 int reg)
          ^^^^^^
For static functions in C files, we tend not to bother marking them
inline any more as the compiler does a pretty good job theses days.

>  {
>  	unsigned int val;
> =20
> -	pci_read_config_dword(mac->iob_pdev, reg, &val);
> +	val =3D in_le32(mac->iob_regs+reg);
> +
>  	return val;

Why not just "return in_le32(mac->iob_regs+reg);" ?
And similarly below?

> +static inline void __iomem * __devinit map_onedev(struct pci_dev *p, int=
 index)
          ^^^^^^                ^^^^^^^^^
Mixing inline and __*init is just plain silly :-)

> +fallback:
> +	/* This is hardcoded and ugly, but we have some firmware versions
> +	 * who don't provide the register space in the device tree. Luckily
           ^^^
"that"

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__23_Aug_2007_10_31_03_+1000_N5WdhekWD3pD01YF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGzNVLTgG2atn1QN8RAtYqAJ44BLpY7ycf+VNZdMOZTt3Jro8oOwCfUo5a
YXoprYiexVRdRxj4dSvIgQA=
=aUb7
-----END PGP SIGNATURE-----

--Signature=_Thu__23_Aug_2007_10_31_03_+1000_N5WdhekWD3pD01YF--
