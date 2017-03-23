From: Alban <albeu@free.fr>
Subject: Re: [PATCH 3/7] ath9k: Add support for reading the EEPROM data
 using the nvmem API
Date: Thu, 23 Mar 2017 15:43:28 +0100
Message-ID: <20170323154328.4bb5db44@avionic-0020>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
        <1489439116-4233-3-git-send-email-albeu@free.fr>
        <1609202.bQK0rlNN3Y@debian64>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Qa.CfbMbWyb.SYL5PtXbDRf"; protocol="application/pgp-signature"
Cc: Alban <albeu@free.fr>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        John Crispin <john@phrozen.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, chrisrblake93@gmail.com
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1609202.bQK0rlNN3Y@debian64>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/Qa.CfbMbWyb.SYL5PtXbDRf
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 14 Mar 2017 00:53:55 +0100
Christian Lamparter <chunkeey@googlemail.com> wrote:

> On Monday, March 13, 2017 10:05:11 PM CET Alban wrote:
> > Currently SoC platforms use a firmware request to get the EEPROM data.
> > This is mostly a hack and rely on using a user-helper scripts which is
> > deprecated. A nicer alternative is to use the nvmem API which was
> > designed for this kind of task.
> >=20
> > Furthermore we let CONFIG_ATH9K_AHB select CONFIG_NVMEM as such
> > devices will generally use this method for loading the EEPROM data.
> >=20
> > Signed-off-by: Alban <albeu@free.fr>
> > ---
> > @@ -654,6 +656,25 @@ static int ath9k_init_softc(u16 devid, struct ath_=
softc *sc,
> >  	if (ret)
> >  		return ret;
> > =20
> > +	/* If the EEPROM hasn't been retrieved via firmware request
> > +	 * use the nvmem API insted.
> > +	 */
> > +	if (!ah->eeprom_blob) {
> > +		struct nvmem_cell *eeprom_cell;
> > +
> > +		eeprom_cell =3D nvmem_cell_get(ah->dev, "eeprom");
> > +		if (!IS_ERR(eeprom_cell)) {
> > +			ah->eeprom_data =3D nvmem_cell_read(
> > +				eeprom_cell, &ah->eeprom_size);
> > +			nvmem_cell_put(eeprom_cell);
> > +
> > +			if (IS_ERR(ah->eeprom_data)) {
> > +				dev_err(ah->dev, "failed to read eeprom");
> > +				return PTR_ERR(ah->eeprom_data);
> > +			}
> > +		}
> > +	}
> > +
> >  	if (ath9k_led_active_high !=3D -1)
> >  		ah->config.led_active_high =3D ath9k_led_active_high =3D=3D 1;
> >   =20
> Are you sure this works with AR93XX SoCs that have the calibration data
> in the OTP?

I only tested this on an ar9132 platform, so it might well be that a
few things are missing for the newer SoC. However this shouldn't break
anything existing as a platform needs to define an nvmem cell on the
athk9 device for this code to be used at all.

Alban

--Sig_/Qa.CfbMbWyb.SYL5PtXbDRf
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJY098QAAoJEHSUmkuduC28pU8P/i3jxIr34un4PVGUm2PtC+Ng
f49Htkd72NLj/srYraNQUquaNvaWUvP6VwRv7SBxHuPPFe7E9cc9pYM2XQmacqFr
EoeFW/1Zf0NhrKNn7pVPlV6+zTfxoxBZ+LpzAOfOnihwKtUwbkNM5bepYRgSjbSN
DT2KoaulFqkvgg3394dHeK33K9WKdhJMKePB6BFNiJs0pKrJ9OA0dU7m5yMKQI3g
7vFi2oduArbfqjeO0KJtIMefsknpxCmX1p+ERP3RxbH/stAA6Wuo7NUKk5afsBUa
CWVJhNp/AFwY9WhnA3a/LygUN7vre+Oz25VTW8IiI2EjszgcG6EiQyaYNuFlErDI
WSyH2jrH7wpDuwrFk64DiA9r1ZYkjlwTELmq181yEa2Hp9HgePHLMNzertgcChc+
OY/DHV/ICtzOgialA8FzOV/DJadjB8rrgcoeCoGXkE5Za6l1+vRgPOD/Pd6J3LTm
QR9Eooj/cb995Im1iWe/zaVoJKZgVD7HRkPL8flmUADqOgeW+p4rw1drW6fUma1h
U2cCcMCBYOIbCrzu2b2BSi+R4EDr/zNRZtzimZxmHv/z0+2cEH8XAq+O5cfxkSKv
1RP8rRX9B5iWwQnfWuhoyOzm5wusfT9dctkm1qdrzUM0hB6g6u4B/jertVwJSzHO
1+TyxIhutQuwiS1a1vo/
=J5ti
-----END PGP SIGNATURE-----

--Sig_/Qa.CfbMbWyb.SYL5PtXbDRf--
