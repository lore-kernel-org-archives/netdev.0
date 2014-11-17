From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Mon, 17 Nov 2014 23:36:26 +0100
Message-ID: <3543341.FmUQFH9nrl@eisbaer>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <54363ED0.605@broadcom.com> <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart4049149.2qD9Hqy0xl"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	Seth Forshee <seth.forshee@canonical.com>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.18.164]:52781 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368AbaKQWoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 17:44:32 -0500
In-Reply-To: <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart4049149.2qD9Hqy0xl
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"

On Thursday 09 October 2014 10:21:12 Rafa=C5=82 Mi=C5=82ecki wrote:
> On 9 October 2014 09:52, Arend van Spriel <arend@broadcom.com> wrote:=

> > I have been staring at differences brcmsmac and our internal driver=
 (which
> > wl is derived from as well). Would you be able to make an mmiotrace=

> > loading
> > wl and brcmsmac.
>=20
> Arend,
>=20
> As you noticed earlier, this is a WiFi card with BT. I've checked
> siutils.c from SDK 7.14.43.7 (got it from Netgear R8000) and it has
> three BCM4313 workarounds:
>=20
>=20
> 1) si_doattach
> SI_MSG(("Applying 4313 WARs\n"));
> si_pmu_chipcontrol(sih, 0, CCTRL_4313_12MA_LED_DRIVE,
> CCTRL_4313_12MA_LED_DRIVE);
>=20
> It's already implemented in bcma, see driver_chipcommon_pmu.c
>=20
>=20
> 2) si_epa_4313war
> /* EPA Fix */
> W_REG(sii->osh, &cc->gpiocontrol,
> R_REG(sii->osh, &cc->gpiocontrol) | GPIO_CTRL_EPA_EN_MASK);
>=20
> This is what you already implement in ai_epa_4313war
>=20
>=20
> 3) si_pmu_synth_pwrsw_4313_war
> I don't think it's implemented.
>=20
>=20
> 4) si_btcombo_p250_4313_war
> I also don't think it's implemented
>=20
>=20
> The last one (si_btcombo_p250_4313_war) looks promising, the comment
> above the function says:
> /** WL/BT control for 4313 btcombo boards >=3D P250 */
> I guess you need to re-implement this function and call it somewhere
> in brcmsmac.

Hi,

I just wanted to ask if there is any progress on this issue since I hav=
en't=20
heard anything for a month. Please let me know if you need any addition=
al=20
information.

Greetings,
Maxi


--nextPart4049149.2qD9Hqy0xl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUanhtAAoJEIHqZH0kK9IVtkMP/0Pu2H09VBPIdeCHQ5xgOo4b
Plbo9R2ql0L1yvr8XPbXk2zBjaRbdCGMucN8ayZg9I5UPH3nIZ7PbZhq/Wtr7jUe
V3gip4ct9IKFtwPXdAXB1Q0i8kIu2TKi6G8MYbZq1RAB1tulUI/XMsFB6egC07jQ
njJnN08aFYbT2KbHl2l3/rhl4qTLsZFCSf9T9VlJKRNoBkH335Ssktcgt/L/F8Ji
gfwoJVSBTTlPRfaxNioN+MbhHL2JmY7YBckZUY5lKHJGo3o8YlNeJMGDvtIdApSB
uq15+0o1VvJ524FOMAUAAcTHhH5eZ65V616YTEY6BbDoi4f/2Dy2yu//UiJH2vjb
XFaHFAG2tpaqm7LqfG8O10sX/tqIN/2buBPs7rQyETdZx1nSIi+HA5/xHXuUrnWa
8KOrJdJqN7kYGjcDQyK+1OSytGPaVdDur6cjwbeRnMtBpHatN6i0euHikLi90sZO
QgpQdVqXfMiL6LKJewDOwcFVirfktNWnHPyf3g9ifArnMqHyPY7PVnHa9yn21BoI
s2OKC7WtHBCWutmMKQLvtT0EIvEmSJCKCHM8qgSANst0/yxSoscxR1wdZ2zZ6SK0
31/K8i7vb8LJ65B83s2OOBuheuhCrFnYoXHk7KWRmhj3gOpf7K+54/48FzUI0m3j
kL7psCPKUMrYjrY/LTAb
=9StG
-----END PGP SIGNATURE-----

--nextPart4049149.2qD9Hqy0xl--
