From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH 2/2 v2] Driver core: reduce duplicated code
Date: Mon, 28 Jun 2010 13:27:25 +0800
Message-ID: <AANLkTikw_wceFTLFKDF5DH9p5Or6r_8G0gVAI91sN2zK@mail.gmail.com>
References: <20100618073950.GA12822@pengutronix.de> <1277129511-2732-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<20100621213846.GB25511@kroah.com> <20100622052314.GA17128@pengutronix.de>
	<AANLkTinMLrXyqKZ76AiWiw6N_glrWWrP-2_aUTzQm5Xr@mail.gmail.com>
	<20100628051606.GA16445@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sascha Hauer <s.hauer@pengutronix.de>, Greg KH <greg@kroah.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
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
In-Reply-To: <20100628051606.GA16445@pengutronix.de>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/6/28 Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>:
> Hi Eric,
>
> On Mon, Jun 28, 2010 at 12:55:45PM +0800, Eric Miao wrote:
>> I suggest you to have a look into arch/arm/mach-mmp/devices.c and
>> arch/arm/mach-mmp/pxa{168,910}.c as well as
>> arch/arm/mach-mmp/include/mach/pxa{168,910}.h, maybe we can find
>> some common practice.
> I think I like this approach in general, I already thought about not
> passing all parameters as function/macro arguments, too. =C2=A0But ma=
ybe this
> becomes too excessive for imx as I would need too many of these devic=
e
> desc for the different imx variants?!
>
> Anyhow a few things I thought when looking in the files you suggested=
:
>
> =C2=A0- Why not use an array for all uart devdescs, maybe the code fo=
r
> =C2=A0 pxa168_add_uart could become a bit smaller then?:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0extern struct pxa_device_desc pxa168_devic=
e_uart[2];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0static inline int pxa168_add_uart(int id)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct pxa_dev=
ice_desc *d =3D pxa168_device_uart + id;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (id < 0 || =
id > 2)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return -EINVAL;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return pxa_reg=
ister_device(d, NULL, 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 (Ditto for the other types obviously.)

That's a good suggestion, yet it came that way for two reasons:

1. the initial naming mess, uart0 was later renamed to uart1, e.g.
2. and the restrictions of PXA{168,910}_DEVICE() macros, these
   macros are handy to simplify the definition, but may require fancy
   tricks to make it support array

>
> =C2=A0- shouldn't all these pxa_device_descs and pxa168_add_$device f=
unctions
> =C2=A0 be __initdata and __init?
>

pxa{168,910}_add_device() are actually 'static inline' so my assumption
is they will be inlined when referenced, otherwise won't occupy any cod=
e
space. The *_descs, however, they are __initdata if you look into the
definitions of PXA{168,910}_DEVICES

> =C2=A0- pxa_register_device is better than my add_resndata function i=
n (at
> =C2=A0 least) one aspect as it sets coherent_dma_mask, too. =C2=A0Thi=
s is
> =C2=A0 something I missed when trying to add mxc-mmc (IIRC) devices.
>
> Thanks
> Uwe
>
> --
> Pengutronix e.K. =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | Uwe Kleine-K=C3=B6nig =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|
> Industrial Linux Solutions =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 | http://www.pengutronix.de/ =C2=A0|
>
