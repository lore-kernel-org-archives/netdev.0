From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH 2/2 v2] Driver core: reduce duplicated code
Date: Mon, 28 Jun 2010 12:55:45 +0800
Message-ID: <AANLkTinMLrXyqKZ76AiWiw6N_glrWWrP-2_aUTzQm5Xr@mail.gmail.com>
References: <20100618073950.GA12822@pengutronix.de> <1277129511-2732-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<20100621213846.GB25511@kroah.com> <20100622052314.GA17128@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, Randy Dunlap <rdunlap@xenotime.net>,
	Dmitry Torokhov <dtor@mail.ru>,
	Anisse Astier <anisse@astier.eu>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Paul Mundt <lethal@linux-sh.org>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20100622052314.GA17128@pengutronix.de>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/6/22 Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>:
> Hi Greg,
>
>> > I changed the semantic slightly to only call
>> > platform_device_add_resources if data !=3D NULL instead of size !=3D=
 0. =C2=A0The
>> > idea is to support wrappers like:
>> >
>> > =C2=A0 =C2=A0 #define add_blablub(id, pdata) \
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 platform_device_register=
_resndata(NULL, "blablub", id, \
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 NULL, 0, pdata, sizeof(struct blablub_platform_data))
>> >
>> > that don't fail if pdata=3DNULL. =C2=A0Ditto for res.
>>
>> That's fine, but why would you want to have a #define for something =
like
>> this? =C2=A0Is it really needed?
> Well, what is really needed? =C2=A0I intend to use it on arm/imx. =C2=
=A0I have
> several different machines using similar SoCs and so I want to have a
> function =C3=A0 la:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct platform_device *__init imx_add_imx=
_i2c(int id,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0resource_size_=
t iobase, resource_size_t iosize, int irq,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct i=
mxi2c_platform_data *pdata)
>
> that builds a struct resource[] and then calls
> platform_device_register_resndata(). =C2=A0And then I have a set of m=
acros
> like:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0#define imx21_add_i2c_imx(pdata) =C2=A0 =C2=
=A0 =C2=A0 =C2=A0\
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0imx_add_imx_i2=
c(0, MX2x_I2C_BASE_ADDR, SZ_4K, MX2x_INT_I2C, pdata)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0#define imx25_add_imx_i2c0(pdata) =C2=A0 =C2=
=A0 =C2=A0 \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0imx_add_imx_i2=
c(0, MX25_I2C1_BASE_ADDR, SZ_16K, MX25_INT_I2C1, pdata)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0##define imx25_add_imx_i2c1(pdata) =C2=A0 =
=C2=A0 =C2=A0\
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0imx_add_imx_i2=
c(1, MX25_I2C2_BASE_ADDR, SZ_16K, MX25_INT_I2C2, pdata)
>
> etc. =C2=A0The final goal is to get rid of files like
> arch/arm/mach-mx3/devices.c.
>

Hi Uwe,

I suggest you to have a look into arch/arm/mach-mmp/devices.c and
arch/arm/mach-mmp/pxa{168,910}.c as well as
arch/arm/mach-mmp/include/mach/pxa{168,910}.h, maybe we can find
some common practice.

>> Anyway, this version looks fine to me, I'll go apply it.
> \o/
>
> Best regards and thanks
> Uwe
>
> --
> Pengutronix e.K. =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | Uwe Kleine-K=C3=B6nig =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|
> Industrial Linux Solutions =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 | http://www.pengutronix.de/ =C2=A0|
>
