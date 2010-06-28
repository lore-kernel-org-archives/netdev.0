From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 2/2 v2] Driver core: reduce duplicated code
Date: Mon, 28 Jun 2010 07:16:06 +0200
Message-ID: <20100628051606.GA16445@pengutronix.de>
References: <20100618073950.GA12822@pengutronix.de> <1277129511-2732-1-git-send-email-u.kleine-koenig@pengutronix.de> <20100621213846.GB25511@kroah.com> <20100622052314.GA17128@pengutronix.de> <AANLkTinMLrXyqKZ76AiWiw6N_glrWWrP-2_aUTzQm5Xr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, Randy Dunlap <rdunlap@xenotime.net>,
	Dmitry Torokhov <dtor@mail.ru>,
	Anisse Astier <anisse@astier.eu>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Paul Mundt <lethal@linux-sh.org>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Miao <eric.y.miao@gmail.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinMLrXyqKZ76AiWiw6N_glrWWrP-2_aUTzQm5Xr@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Mon, Jun 28, 2010 at 12:55:45PM +0800, Eric Miao wrote:
> I suggest you to have a look into arch/arm/mach-mmp/devices.c and
> arch/arm/mach-mmp/pxa{168,910}.c as well as
> arch/arm/mach-mmp/include/mach/pxa{168,910}.h, maybe we can find
> some common practice.
I think I like this approach in general, I already thought about not
passing all parameters as function/macro arguments, too.  But maybe thi=
s
becomes too excessive for imx as I would need too many of these device
desc for the different imx variants?!

Anyhow a few things I thought when looking in the files you suggested:

 - Why not use an array for all uart devdescs, maybe the code for
   pxa168_add_uart could become a bit smaller then?:

	extern struct pxa_device_desc pxa168_device_uart[2];
	...
	static inline int pxa168_add_uart(int id)
	{
		struct pxa_device_desc *d =3D pxa168_device_uart + id;

		if (id < 0 || id > 2)
			return -EINVAL;

		return pxa_register_device(d, NULL, 0);
	}

   (Ditto for the other types obviously.)

 - shouldn't all these pxa_device_descs and pxa168_add_$device function=
s
   be __initdata and __init?

 - pxa_register_device is better than my add_resndata function in (at
   least) one aspect as it sets coherent_dma_mask, too.  This is
   something I missed when trying to add mxc-mmc (IIRC) devices.

Thanks
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
