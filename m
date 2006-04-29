From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 2/3] rt2x00 drivers: rt61pci
Date: Sat, 29 Apr 2006 17:35:09 +0200
Message-ID: <200604291735.12720.IvDoorn@gmail.com>
References: <200604291147.26887.IvDoorn@gmail.com> <20060429145850.GA2456@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1460294.XTBZPNi2ZS";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:50764 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1750745AbWD2PeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2006 11:34:01 -0400
Received: by nproxy.gmail.com with SMTP id n29so1747669nfc
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2006 08:33:59 -0700 (PDT)
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060429145850.GA2456@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1460294.XTBZPNi2ZS
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 29 April 2006 16:58, Francois Romieu wrote:
> Ivo van Doorn <ivdoorn@gmail.com> :
> > From: Ivo van Doorn <IvDoorn@gmail.com>
> >=20
> > This adds the rt61pci driver to the tree=20
> >=20
> > Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
> >=20
> > Available on server:
> > http://mendiosus.nl/rt2x00/rt61pci.diff
>=20
> It is nice that you are doing this work but I still don't feel
> the same while reading your patches or tg3.c/sky2.c (for instance).
>=20
> +static inline void
> +rt2x00_register_read(
>=20
> grep accepts regular expression and ctags works quite well.
> Why do you cut an expression which would fit on a 80 columns line ?

Part of the coding style I use. Bad habit, I know.
I'll change them.

> [...]
> +	u32		reg;
> +	u8		counter;
>=20
> It's (mostly) fine with me if you want to align the declaration
> but why do you use more than the minimum amount of required tab ?
> Elsewhere the variable is completely shifted right: beyond a point,
> it does not make the code more readable.

Unless I am mistaken, 2 tabs are used at a max.
Perhaps in some cases it is more, because the variable beneath
is a long structure name. I'll go over them again, and check where
they could be minimized.

> Not sure if 'unsigned int' would be welcome instead of 'u8' for
> counter.

Not sure about that either. I usually choose the type of the counter
depending on the max size of that counter.

> [...]
> +	for (counter =3D 0; counter < REGISTER_BUSY_COUNT; counter++) {
> +		rt2x00_register_read(rt2x00pci, PHY_CSR3, &reg);
>=20
> "i" is more idiomatic C-kernel than "counter".

Perhaps, but I prefer the usage of the name "counter".
I am not sure if there is a coding style about this? If so I could rename "=
counter" to "i".

> [...]
> +	if (rt2x00_rf(&rt2x00pci->chip, RF5225)
> +	|| rt2x00_rf(&rt2x00pci->chip, RF2527))
>=20
> If you put the || at the end of the previous line, you can indent
> the second line with four withspaces, thus aligning the content.

I'll create a bugreport in the rt2x00 project bugzilla
with some of the coding style change requests.
It could take a while before a patch will be ready since I put higher
priority to get the drivers working correctly. ;)

> [...]
> +static void
> +rt61pci_init_firmware_cont(const struct firmware *fw, void *context)
> [...]
> +	for (counter =3D 0; counter < 100; counter++) {
> +		rt2x00_register_read(rt2x00pci, MCU_CNTL_CSR, &reg);
> +		if (rt2x00_get_field32(reg, MCU_CNTL_CSR_READY))
> +			break;
> +		msleep(1);
> +	}
> +
> +	if (counter =3D=3D 1000) {
>                           ^ -> typo

Good call. Thanks. :)

> [...]
> static int
> +rt61pci_init_firmware(struct rt2x00_pci *rt2x00pci)
> +{
> +	/*
> +	 * Read correct firmware from harddisk.
> +	 */
> +	if (rt2x00_rt(&rt2x00pci->chip, RT2561))
> +		return request_firmware_nowait(THIS_MODULE, 1,
> +			"rt2561.bin", &rt2x00pci->pci_dev->dev, rt2x00pci,
> +			rt61pci_init_firmware_cont);
> +	else if (rt2x00_rt(&rt2x00pci->chip, RT2561s))
> +		return request_firmware_nowait(THIS_MODULE, 1,
> +			"rt2561s.bin", &rt2x00pci->pci_dev->dev, rt2x00pci,
> +			rt61pci_init_firmware_cont);
> +	else if (rt2x00_rt(&rt2x00pci->chip, RT2661))
> +		return request_firmware_nowait(THIS_MODULE, 1,
> +			"rt2661.bin", &rt2x00pci->pci_dev->dev, rt2x00pci,
> +			rt61pci_init_firmware_cont);
>=20
> 	struct {
> 		char *name;
> 		unsigned int chip;
> 	} firmware[] =3D {
> 		{ "rt2561.bin",		RT2561 },
> 		{ "rt2561s.bin",	RT2561s },
> 		{ "rt2561.bin",		RT2661 }
> 	};
> 	int rc =3D -EINVAL;
> 	unsigned int i;
>=20
> 	for (i =3D 0; i < ARRAY_SIZE(firmware); i++) {
> 		if (!rt2x00_rt(&rt2x00pci->chip, firmware[i].chip))=20
> 			continue;
> 		rc =3D request_firmware_nowait(THIS_MODULE, 1,
> 			firmware[i].name, &rt2x00pci->pci_dev->dev,
> 			rt2x00pci, rt61pci_init_firmware_cont);
> 		break;
> 	}
> 	return rc;

Sounds good to me.
I'll make this fix part of next patch series.

--nextPart1460294.XTBZPNi2ZS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEU4ewaqndE37Em0gRAqOoAJ9GJBhBE/QITFVU5SNNf6LHoECEiwCfULTx
7KAjnHvaFpsIoqnLmWY/OzA=
=WOfp
-----END PGP SIGNATURE-----

--nextPart1460294.XTBZPNi2ZS--
