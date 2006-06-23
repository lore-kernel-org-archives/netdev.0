From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Fri, 23 Jun 2006 23:35:57 +0200
Message-ID: <200606232336.01344.IvDoorn@gmail.com>
References: <200605251716.00742.IvDoorn@gmail.com> <200606232051.37518.IvDoorn@gmail.com> <20060623193246.GC6270@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1228132.GafAYsNG7M";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Stefan Rompf <stefan@loplof.de>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:26015 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1752084AbWFWVbu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 17:31:50 -0400
Received: by nf-out-0910.google.com with SMTP id m19so271552nfc
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 14:31:49 -0700 (PDT)
To: Vojtech Pavlik <vojtech@suse.cz>
In-Reply-To: <20060623193246.GC6270@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1228132.GafAYsNG7M
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

> > So basicly 1 input device for every single wireless driver that impleme=
nts
> > the RF-Kill button?
>=20
> Yes.
>=20
> > Is there any particular reason for not using 1 input device shared by a=
ll?
>=20
> Yes.
>=20
> In the unlikely case where there are two devices which implement a
> rfkill button in the system, the input core doesn't have a way how to
> express the state of these two different buttons with the same meaning
> (and hence the same code - KEY_RFKILL) in a single input device.
>=20
> You'd have to assign a range of codes to the shared device, which goes
> agains the design of the Linux inpu layer.
>=20
> Anyway, for the most common case, where you have a single RF-Kill key in
> the whole system, there will not be any difference to using the shared
> device.
>=20
> What do you consider the benefits of using a shared input device?

Well it is a matter of preference, especially on how this rfkill.ko would
be implemented. When the user has 2 buttons, should all radios
(wifi, bluetooth etc) be switched off by pressing each individual key
or just 1 key to switch off everything.
But now that I am further thinking about this, (and looking on how
my laptop currently works with 1 wifi button and 1 bluetooth button)
perhaps multiple input devices would indeed be best.
userspace can decide if more interfaces should be attached to the button
or not. And this would be the preferred situation.

> > Userspace could switch off the radio by using the txpower ioctl of
> > ifdown/ifup. Or should an approach call be implemented?
>=20
> I'm an input guy, the details of how to disable the radio I'll leave up
> to you - the WiFi folks on netdev.

:)

> You may want to consider that the radio chip usually synthesizes a
> frequency that it mixes with the incoming signal to frequency-shift it
> to a low frequency which then can be demodulated. Because of that, even
> the receiver, when working, can affect devices nearby. This is why FM
> radio receivers are not allowed on airplanes.
>=20
> Hardware RF-Kill disables both RX and TX, by stopping the radio chip.
> Setting TX power to an extremely low value might not be the same.
>=20
> On the other hand, you may define in the API that setting TX power to
> zero also disables the receiver.

ok, no need for new ioctl calls in that case I believe.
Using the txpower the radio can be switched on and off, without giving a lo=
w or 0 as value.
But the decision to use ifup and ifdown or iwconfig txpower on/off could be=
 done later,
since it can handled in user space.

> > > 	3) ACPI buttons drivers, and keyboard drivers will generate KEY_RFKI=
LL
> > > 	on machines where RF-Kill keys are reported using ACPI events or
> > > 	keyboard scancodes.
> >=20
> > Why both an input and ACPI event?
> > With ACPI restricted to x86 only, wouldn't a more generic approach be d=
esired?
>=20
> I was talking about the ACPI EC sending us an event. This is how are
> ACPI buttons implemented in certain notebooks. I definitely don't want
> to use the acpi events as received by acpid now as the interface. Sorry
> for the confusion.

ah ok. :)

> > > 	3) A rfkill.ko input handler module will be implemented, that listen=
s to
> > > 	the SW_RFKILL and KEY_RFKILL events from all devices in the system, =
and
> > > 	will enable/disable radios on all 802.11 devices in the system.
> > >
> > > The above will make the RF-Kill button work under all real scenarios =
as
> > > user expects - it will enable/disable the radio. In the case where a
> > > user has an additional PCMCIA card, both the radios will be disabled =
by
> > > presing the RF-Kill button, which is arguably what the user expects.
> > > Even BlueTooth or other RF technologies (CDMA, EDGE) can hook into th=
is
> > > mechanism.
> > >=20
> > > 	4) When userspace wants to take over the control over RF-Kill, and s=
tart
> > > 	additional services based on that, it can open the input devices to =
get
> > > 	the state of the buttons/switches, AND it can issue the EVIOCGRAB
> > > 	ioctl() to prevent the rfkill.ko and any other handlers from getting=
 the
> > > 	events.
> > >
> > > This allows simple implementation of dbus notifications and
> > > NetworkManager-style configuration of network interfaces.
>=20

--nextPart1228132.GafAYsNG7M
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEnF7BaqndE37Em0gRAg5iAKDJw/E9d87KnjcFtuJweiB7f/ATKQCeL/r6
UDv1Y16my+wVPlZT1Sco+k8=
=7eum
-----END PGP SIGNATURE-----

--nextPart1228132.GafAYsNG7M--
