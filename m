From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 2/2 v2] Driver core: reduce duplicated code
Date: Tue, 22 Jun 2010 07:23:14 +0200
Message-ID: <20100622052314.GA17128@pengutronix.de>
References: <20100618073950.GA12822@pengutronix.de> <1277129511-2732-1-git-send-email-u.kleine-koenig@pengutronix.de> <20100621213846.GB25511@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	Dmitry Torokhov <dtor@mail.ru>,
	Anisse Astier <anisse@astier.eu>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Paul Mundt <lethal@linux-sh.org>,
	Eric Miao <eric.y.miao@gmail.com>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100621213846.GB25511@kroah.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

> > I changed the semantic slightly to only call
> > platform_device_add_resources if data !=3D NULL instead of size !=3D=
 0.  The
> > idea is to support wrappers like:
> >=20
> > 	#define add_blablub(id, pdata) \
> > 		platform_device_register_resndata(NULL, "blablub", id, \
> > 			NULL, 0, pdata, sizeof(struct blablub_platform_data))
> >=20
> > that don't fail if pdata=3DNULL.  Ditto for res.
>=20
> That's fine, but why would you want to have a #define for something l=
ike
> this?  Is it really needed?
Well, what is really needed?  I intend to use it on arm/imx.  I have
several different machines using similar SoCs and so I want to have a
function =E0 la:

	struct platform_device *__init imx_add_imx_i2c(int id,
		resource_size_t iobase, resource_size_t iosize, int irq,
		const struct imxi2c_platform_data *pdata)

that builds a struct resource[] and then calls
platform_device_register_resndata().  And then I have a set of macros
like:

	#define imx21_add_i2c_imx(pdata)	\
		imx_add_imx_i2c(0, MX2x_I2C_BASE_ADDR, SZ_4K, MX2x_INT_I2C, pdata)
	#define imx25_add_imx_i2c0(pdata)	\
		imx_add_imx_i2c(0, MX25_I2C1_BASE_ADDR, SZ_16K, MX25_INT_I2C1, pdata)
	##define imx25_add_imx_i2c1(pdata)	\
		imx_add_imx_i2c(1, MX25_I2C2_BASE_ADDR, SZ_16K, MX25_INT_I2C2, pdata)

etc.  The final goal is to get rid of files like
arch/arm/mach-mx3/devices.c.

> Anyway, this version looks fine to me, I'll go apply it.
\o/

Best regards and thanks
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
