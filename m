From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ssb: mark ssb_bus_register as __maybe_unused
Date: Tue, 03 Nov 2015 17:42:26 +0100
Message-ID: <7423389.1hNz9LlOCE@wuerfel>
References: <5928552.0ccybX7Zly@wuerfel> <20151103172721.04533081@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	linux-kernel@vger.kernel.org, zajec5@gmail.com,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
To: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151103172721.04533081@wiggum>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 03 November 2015 17:27:21 Michael B=FCsch wrote:
> On Tue, 03 Nov 2015 16:05:51 +0100
> Arnd Bergmann <arnd@arndb.de> wrote:
>=20
> > The SoC variant of the ssb code is now optional like the other
> > ones, which means we can build the framwork without any
> > front-end, but that results in a warning:
> >=20
> > drivers/ssb/main.c:616:12: warning: 'ssb_bus_register' defined but =
not used [-Wunused-function]
> >=20
> > This annotates the ssb_bus_register function as __maybe_unused to
> > shut up the warning. A configuration like this will not work on
> > any hardware of course, but we still want this to silently build
> > without warnings if the configuration is allowed in the first
> > place.
>=20
>=20
> Is there a simple way to disallow this configuration?

I could not come up with a simple one. We could turn 'CONFIG_SSB' into
a silent option and have it selected by each bus specific driver,
but then we also have to change all the device drivers (usb and
wireless I guess) to use 'depends on' rather than 'select'.

	Arnd
