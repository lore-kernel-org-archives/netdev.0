From: Marc Dietrich <marvin24@gmx.de>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device properties with rfkill_gpio
Date: Tue, 23 Feb 2016 14:42:55 +0100
Message-ID: <2927215.6IlWnjRTgT@fb07-iapwap2>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com> <4048115.S0MS1KQXCA@fb07-iapwap2> <2463567.tt0f0ingYr@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart80904992.30kfgfXpzZ"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Thierry Reding <thierry.reding@gmail.com>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org,
	Alexandre Courbot <gnurou@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2463567.tt0f0ingYr@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart80904992.30kfgfXpzZ
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Am Dienstag, 23. Februar 2016, 14:17:17 CET schrieb Arnd Bergmann:
> On Tuesday 23 February 2016 11:38:52 Marc Dietrich wrote:
> > Am Dienstag, 23. Februar 2016, 11:31:40 CET schrieb Arnd Bergmann:
> > > On Tuesday 23 February 2016 11:15:31 Arnd Bergmann wrote:
> > > > On Thursday 18 February 2016 21:04:49 Johannes Berg wrote:
> > > > > On Tue, 2016-01-26 at 09:42 +0100, Johannes Berg wrote:
> > > > Just for my curiosity: what is the difference between a rfkill-gpio
> > > > device and a gpio-keys device with a KEY_RFKILL code?
> > > > 
> > > > arch/arm/boot/dts/bcm4708-netgear-r6250.dts and others seem to
> > > > do the second approach in DT so they don't need to create the
> > > > platform device.
> > > 
> > > I found the answer now (after discussing on IRC): just
> > > for reference: KEY_RFKILL is for sending the event to the kernel
> > > when a user presses the gpio butting, this rfkill-gpio turns
> > > the devices on or off when after an RFKILL event is received.
> > 
> > yes, paz00 has no hw key. rfkill is triggered via software (rfkill) only.
> > The problem in the past was how to describe such a device in the device
> > tree.
> > 
> > Strictly speaking, there is no rfkill device hardware (just an interface).
> > The only hardware that exists is in our case is connected to a hard wired
> > usb bus (wifi dongle), which makes it complicated to attach a DT property
> > or subdevice to it. And a standalone device-tree entry for a non hardware
> > device was rejected in the past.
> 
> Ah, so the problem of attaching DT properties to a USB device has recently
> been solved, see subject "USB: core: let USB device know device node".
> 
> Would that work for you? With this, the USB driver can simply look at
> the optional DT properties of the USB function to implement its rfkill
> callbacks.

oh, that looks indeed interesting. The question is now if rfkill is a property 
of a device or a subdevice itself. The latter one would only require addition 
of device-tree instantiation of rfkill, while with the former one, the (or 
all) usb driver(s) need to be modified to accept device tree properties, 
especially gpios. The driver would then be responsible to add an rfkill 
"device".

IMHO (and unfortunately), it's just a property (a way to specify the relevant 
gpios), making the solution again hard to archive.

Marc

--nextPart80904992.30kfgfXpzZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWzGHfAAoJEKyeR39HFBtoe1UH/2Fdlh0TLhqjzlJZPxxCRR7l
wKRa0DnSmn5XD8m2pker+HDU20xIE5mEP8cli1EAewo+GL34jwXvfjxqhxAcoOFT
oWUFpMsF5WbpmeWmdbr2wG+unPigZu3nPV14QHd4sqzLdmj6WSj0IL3l3ih6GYKy
Nus0LxYxLjy/RAW0MIu0yeD7s6Bczb6V6n/GwZD6niRbjlvsCzVCUXxpL2H58l7o
up1Oe/Ve/+DmqUyEHoAN3vcu82f/5dTsfO8eogAEsiw+ufS4np89Jjq9m5GhDwIo
QudHyg6NlSLN4ZO8FOJKdESHINDP1MzJ+zSNRNrhDyeNp1jDtY9DDbZZztlwNzE=
=tBpW
-----END PGP SIGNATURE-----

--nextPart80904992.30kfgfXpzZ--
