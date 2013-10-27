From: Sebastian Reichel <sre@debian.org>
Subject: Re: [PATCH 2/4] wl1251: move power GPIO handling into the driver
Date: Sun, 27 Oct 2013 21:12:20 +0100
Message-ID: <20131027201218.GA4414@earth.universe>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
 <1382890469-25286-3-git-send-email-sre@debian.org>
 <1382891056.102746625@f315.i.mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="CE+1k2dSO48ffgeK"
Cc: Luciano Coelho <luca@coelho.fi>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Tony Lindgren <tony@atomide.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Stephen Warren <swarren@wwwdotorg.org>,
	linux-doc@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Rob Herring <rob.herring@calxeda.com>,
	linux-kernel@vger.kernel.org,
	Sachin Kamat <sachin.kamat@linaro.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Felipe Balbi <balbi@ti.com>, Rob Landley <rob@landley.net>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Alexander Shiyan <shc_work@mail.ru>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382891056.102746625@f315.i.mail.ru>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Oct 27, 2013 at 08:24:16PM +0400, Alexander Shiyan wrote:
> > Move the power GPIO handling from the board code into
> > the driver. This is a dependency for device tree support.
> >=20
> > Signed-off-by: Sebastian Reichel <sre@debian.org>
> > ---
> >  arch/arm/mach-omap2/board-omap3pandora.c     |  2 ++
> >  arch/arm/mach-omap2/board-rx51-peripherals.c | 11 ++--------
> >  drivers/net/wireless/ti/wl1251/sdio.c        | 21 +++++++++++++-----
> >  drivers/net/wireless/ti/wl1251/spi.c         | 33 ++++++++++++++++++--=
--------
> >  drivers/net/wireless/ti/wl1251/wl1251.h      |  2 +-
> >  include/linux/wl12xx.h                       |  2 +-
> >  6 files changed, 43 insertions(+), 28 deletions(-)
> ...
> > diff --git a/include/linux/wl12xx.h b/include/linux/wl12xx.h
> > index b516b4f..a9c723b 100644
> > --- a/include/linux/wl12xx.h
> > +++ b/include/linux/wl12xx.h
> > @@ -49,7 +49,7 @@ enum {
> >  };
> > =20
> >  struct wl1251_platform_data {
> > -	void (*set_power)(bool enable);
> > +	int power_gpio;
> >  	/* SDIO only: IRQ number if WLAN_IRQ line is used, 0 for SDIO IRQs */
> >  	int irq;
> >  	bool use_eeprom;
> > --=20
>=20
> What a reason for not using regulator API here with GPIO-based
> regulator?

I think this pin is not used as power supply, but like an enable pin
for low power states. Of course the regulator API could still be
(mis?)used for this, but I think it would be the first linux device
driver doing this.

Note: I don't have wl1251 documentation.

-- Sebastian

--CE+1k2dSO48ffgeK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBCAAGBQJSbXOhAAoJENju1/PIO/qaWF4P+QHuK97jolVl7yfy/U0+EUDs
I71tbvIWvi3t1TryAUzpEbjQ3xOn4kcXiKC6lQd5Ugdeo1CYuiXcfFY7T1Vl0OZo
YpWvEWT3qhi2Mfgmw07wL1WTcDqpzeYhDm65fbjSs2fjeSRH5baTyOk6UJuvXeWv
H/n3fyeaRQBWKAjoURyzwodRMsvmWtVswgIFdghpfdctwLX2Rt2EJOPYlp9a+q60
tl52WLtPZecICcDmgSrncHeoaNeb9r1S6FYhTzTLmvnpPoyv5fW/cgqCflctoRbx
THhYeohVHOTJ7sE/O9GGeOHHPcjQowhO1OX8LszsZboSR+fiWv71QwpzK3AzcZK4
Bbair8sd/obxklir1XwvT6KTAPX9J2Ws80dxNPwEzEFZJ2+kIUSDiHkHEqZk/erX
IkNgQ1IAkpv/YzTHSm+TOkXlU7sAn5DxLerWx1rAG7Q4P14+neAsjazTkB/z42sT
v2OxciLhXagecBnrYMfw6Tq6/KVJlq8J/3FKQuavxlg1n+N2u74PyBfe9EHoxELo
ZRQAIqmixr9rAgsIQIdR0M2lF6ZFSANz9bny8WssfWyQ4pcATvaMkcebrg2hi/vb
K526DlqDD2oxrSOIJW3mNu31UFx2MVGvybOnCh9KfneiqpX0ET07gmesr/yBRLW2
Cos9K3MESexvQzDiHWgr
=7NT/
-----END PGP SIGNATURE-----

--CE+1k2dSO48ffgeK--
