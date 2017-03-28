From: Alban <albeu-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 1/7] Documentation: dt: net: Update the ath9k binding
 for SoC devices
Date: Tue, 28 Mar 2017 10:44:41 +0200
Message-ID: <20170328104441.5feedcf4@avionic-0020>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
        <1897671.fKa4XTnU1K@debian64>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/6+FBF53a/FqDMVa4AZ+nouB"; protocol="application/pgp-signature"
Cc: Alban <albeu-GANU6spQydw@public.gmane.org>,
        QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        m@kresin.me
To: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1897671.fKa4XTnU1K@debian64>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Sig_/6+FBF53a/FqDMVa4AZ+nouB
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 27 Mar 2017 18:11:15 +0200
Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:

> On Monday, March 13, 2017 10:05:09 PM CEST Alban wrote:
> > The current binding only cover PCI devices so extend it for SoC devices.
> >=20
> > Most SoC platforms use an MTD partition for the calibration data
> > instead of an EEPROM. The qca,no-eeprom property was added to allow
> > loading the EEPROM content using firmware loading. This new binding
> > replace this hack with NVMEM cells, so we also mark the qca,no-eeprom
> > property as deprecated in case anyone ever used it. =20
>=20
> Please don't mark "qca,no-eeprom" as deprecated then.
> If some devices geniously need to rely on userspace for extracting=20
> and processing the calibration data, it should be stay a
> optional properties.

Deprecated just mean that it shouldn't be used for new devices. But as
it is not used by any board, misuse the firmware loading API and
firmware loader user helper are deprecated in udev, I find we could also
just drop it.

> For example: A device that can't do easily without "qca,no-eeprom" is
> the AVM FRITZ!WLAN Repeater 300E. For this device, the caldata=20
> is stored in the flash, however for whatever reason the vendor
> choose to "reverse" it. (like completely back to front, not byteswapped
> or something). So an extra "unreversing step" is required. So, it would
> require some sort of a special nvmem-provider-processor as an=20
> alternative.

Or just handle this special eeprom format in the ath9k driver. I doubt
that this case is so common that it would justify adding a whole new
layer to nvmem.

> > Signed-off-by: Alban <albeu-GANU6spQydw@public.gmane.org>
> > ---
> > diff --git a/Documentation/devicetree/bindings/net/wireless/qca,ath9k.t=
xt b/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt
> > index b7396c8..61f5f6d 100644
> > --- a/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt
> > +++ b/Documentation/devicetree/bindings/net/wireless/qca,ath9k.txt
> > @@ -27,16 +27,34 @@ Required properties:
> >  			- 0034 for AR9462
> >  			- 0036 for AR9565
> >  			- 0037 for AR9485
> > +		For SoC devices the compatible should be "qca,<soctype>-wmac"
> > +		and one of the following fallbacks:
> > +			- "qca,ar9100-wmac"
> > +			- "qca,ar9330-wmac"
> > +			- "qca,ar9340-wmac"
> > +			- "qca,qca9550-wmac"
> > +			- "qca,qca9530-wmac"
> >  - reg: Address and length of the register set for the device.
> > =20
> > +Required properties for SoC devices:
> > +- interrupt-parent: phandle of the parent interrupt controller.
> > +- interrupts: Interrupt specifier for the controllers interrupt.
> > +
> >  Optional properties:
> > +- mac-address: See ethernet.txt in the parent directory
> > +- local-mac-address: See ethernet.txt in the parent directory
> > +- clock-names: has to be "ref"
> > +- clocks: phandle of the reference clock
> > +- resets: phandle of the reset line
> > +- nvmem-cell-names: has to be "eeprom" and/or "address"
> > +- nvmem-cells: phandle to the eeprom nvmem cell and/or to the mac addr=
ess
> > +		nvmem cell.
> > +
> > +Deprecated properties:
> >  - qca,no-eeprom: Indicates that there is no physical EEPROM
> > connected to the ath9k wireless chip (in this case the calibration /
> >  			EEPROM data will be loaded from userspace
> > using the kernel firmware loader).
> > -- mac-address: See ethernet.txt in the parent directory
> > -- local-mac-address: See ethernet.txt in the parent directory
> > - =20
> It sounds like you want to deprecate mac-address and
> local-mac-address as well. If so you sould add this to the commit as
> well. From my point of view, people mostly flat-out patched the
> eeprom-image if they wanted to set the mac-address. However, this was
> an extra step, if nvmem does away with it, I'm completely fine with
> deprecating these properties.

The produced diff is very misleading because the mac-address properties
get lumped with the other new optional  properties. But if you look
closely it just move qca,no-eeprom to the deprecated section.

Alban

--Sig_/6+FBF53a/FqDMVa4AZ+nouB
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJY2iJ5AAoJEHSUmkuduC28HZUQAKay2wfn22z0Oe8XcWBhgiF+
X+Ce/dFx5/ak0W+/wEG+/Sy/99BUO0FdN4I954c6gjz7ehNstBzAB+3h40SM+4Xy
wee/HjN+I4gDqEpffzP5iYkHlu82VDRyF71uoHH3kqCUQr98/gWDb/a+YtlzdmmY
sXTtq+pMnzGuFtXCTcqm59gsoeTKhYRC4q4vsImdydNtg8SIrOsu+AQZ9sl5Fdvy
el4716q+sDI2+6FrSdnXTawRHSpUOOuWDAxo8eyzmk8QwA5qKDIrwsf7+D8axf+K
U1fuCNzoZQ1omm/TRUFir9rrkcGA5o8/XdNL8XeWSd+MDqvaHOpLI64BHdV4XYTr
hmRzy/DQ0F0Yv3FRPVCHy2K4ChpT/U7ASethPY6IN0rstPc3x8i/FzLkzhHPIHtZ
p+3+fV+LbBnCdCjtPj0z8OeCtezJNrPuTn5w4ErcYNJdvs1SE7+XsQss5khnm9Eu
LmIBz4Vdv1WwO9kFdOjsAAAnQMJjTTt6In0M7syTlOsMw96fpHp8n7+foKzJRkRp
XVowDaygE0IL9TLG8n7Uk5kmHlGiJNiPs/m1bU+Dju/1qS10QsBCos9iPmqJVQ50
vPnl3+ZliJ1hiQX7wyLgCRtnF2+8KeIT0q335+/DJ7oTcm7jCHIRDkOENCw/joAL
G84R+UdvHci3+wHKv/yV
=1tng
-----END PGP SIGNATURE-----

--Sig_/6+FBF53a/FqDMVa4AZ+nouB--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
