From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2/2 v2] Driver core: reduce duplicated code
Date: Mon, 21 Jun 2010 14:38:46 -0700
Message-ID: <20100621213846.GB25511@kroah.com>
References: <20100618073950.GA12822@pengutronix.de>
 <1277129511-2732-1-git-send-email-u.kleine-koenig@pengutronix.de>
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
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1277129511-2732-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 21, 2010 at 04:11:44PM +0200, Uwe Kleine-K=F6nig wrote:
> This makes the two similar functions platform_device_register_simple
> and platform_device_register_data one line inline functions using a n=
ew
> generic function platform_device_register_resndata.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> ---
> Hello,
>=20
> still unsolved is the naming issue, what do you think about
> platform_device_register?

We already have a platform_device_register() function :)

> I marked the new function as __init_or_module in a separate patch to
> make reverting it a bit easier, still I think it should be possible t=
o
> fix the caller if a problem occurs.
>=20
> I changed the semantic slightly to only call
> platform_device_add_resources if data !=3D NULL instead of size !=3D =
0.  The
> idea is to support wrappers like:
>=20
> 	#define add_blablub(id, pdata) \
> 		platform_device_register_resndata(NULL, "blablub", id, \
> 			NULL, 0, pdata, sizeof(struct blablub_platform_data))
>=20
> that don't fail if pdata=3DNULL.  Ditto for res.

That's fine, but why would you want to have a #define for something lik=
e
this?  Is it really needed?

Anyway, this version looks fine to me, I'll go apply it.

thanks,

greg k-h
