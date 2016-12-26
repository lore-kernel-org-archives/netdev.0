From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Mon, 26 Dec 2016 17:35:59 +0100
Message-ID: <20161226163559.GB27087@amd>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
 <e728586e-80bf-c9e0-0063-71da4c4aba85@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="H1spWtNR+x+ondvy"
Cc: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
        Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:51933 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753177AbcLZQhE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 11:37:04 -0500
Content-Disposition: inline
In-Reply-To: <e728586e-80bf-c9e0-0063-71da4c4aba85@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--H1spWtNR+x+ondvy
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun 2016-12-25 21:15:40, Arend Van Spriel wrote:
> On 24-12-2016 17:52, Pali Roh=E1r wrote:
> > NVS calibration data for wl1251 are model specific. Every one device wi=
th
> > wl1251 chip has different and calibrated in factory.
> >=20
> > Not all wl1251 chips have own EEPROM where are calibration data stored.=
 And
> > in that case there is no "standard" place. Every device has stored them=
 on
> > different place (some in rootfs file, some in dedicated nand partition,
> > some in another proprietary structure).
> >=20
> > Kernel wl1251 driver cannot support every one different storage decided=
 by
> > device manufacture so it will use request_firmware_prefer_user() call f=
or
> > loading NVS calibration data and userspace helper will be responsible to
> > prepare correct data.
>=20
> Responding to this patch as it provides a lot of context to discuss. As
> you might have gathered from earlier discussions I am not a fan of using
> user-space helper. I can agree that the kernel driver, wl1251 in this
> case, should be agnostic to platform specific details regarding storage
> solutions and the firmware api should hide that. However, it seems your
> only solution is adding user-space to the mix and changing the api
> towards that. Can we solve it without user-space help?

Answer is no, due to licensing. But that's wrong question to ask.

Right question is "should we solve it without user-space help"?

Answer is no, too. Way too complex. Yes, it would be nice if hardware
was designed in such a way that getting calibration data from kernel
is easy, and if you design hardware, please design it like that. But
N900 is not designed like that and getting the calibration through
userspace looks like only reasonable solution.

Now... how exactly to do that is other question. (But this is looks
very reasonable. Maybe I'd add request_firmware_with_flags(, ...int
flags), but.. that's a tiny detail.). But userspace needs to be
involved.

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--H1spWtNR+x+ondvy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhhRu8ACgkQMOfwapXb+vIgUwCfXm4W4fWCMN8HUGClm4S7Dq0c
PeUAmQGyC3PyPSWR97APVbBCQxpQnIhf
=OLJ0
-----END PGP SIGNATURE-----

--H1spWtNR+x+ondvy--
