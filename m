From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Fri, 23 Jun 2006 20:51:33 +0200
Message-ID: <200606232051.37518.IvDoorn@gmail.com>
References: <200605251716.00742.IvDoorn@gmail.com> <20060622175546.7eebebb4@griffin.suse.cz> <20060623110819.GA29574@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1563790.ktngKqy3qG";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Stefan Rompf <stefan@loplof.de>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:55941 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751917AbWFWSr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 14:47:26 -0400
Received: by nf-out-0910.google.com with SMTP id o60so522902nfa
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 11:47:24 -0700 (PDT)
To: Vojtech Pavlik <vojtech@suse.cz>
In-Reply-To: <20060623110819.GA29574@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1563790.ktngKqy3qG
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

> > On Sat, 17 Jun 2006 17:05:55 +0200, Ivo van Doorn wrote:
> > > With this approach more buttons can be registered,
> > > it includes the optional field to report an update of the key status
> > > to the driver that registered it, and it supports for non-polling key=
s.
> >=20
> > I think this is not specific to networking anymore, so it should go to
> > lkml. Please be sure to Cc: input devices maintainer, Dmitry Torokhov.
> >=20
> > Regarding rfkill button, I talked about that with Vojtech Pavlik (Cc:ed)
> > and he suggests this solution:
> >=20
> > - driver is responsible for turning on/off radio when the input device
> >   is not opened;
> > - when something opens the input device, it receives input events and=20
> >   gets responsible to turn on/off the radio (by ioctl or putting the=20
> >   network interfaces up/down).
> >=20
> > This is of course not possible for all hardware, but it gives the most
> > flexibility while keeping the possibility to switch of the radio without
> > userspace support.
> =20
> Let me elaborate a little bit on the possible implementation:
>=20
> 	1) 802.11 card drivers will implement an input device for each card in
> 	the system that has a user-controlled RF-Kill button or switch.

So basicly 1 input device for every single wireless driver that implements
the RF-Kill button?
Is there any particular reason for not using 1 input device shared by all?

> 	2) 802.11 card drivers will implement an interface to enable/disable the
> 	radio, be it through a call, ioctl, or whatever, that is accessible from
> 	both the kernel and userspace.

Userspace could switch off the radio by using the txpower ioctl of
ifdown/ifup. Or should an approach call be implemented?

> 	3) ACPI buttons drivers, and keyboard drivers will generate KEY_RFKILL
> 	on machines where RF-Kill keys are reported using ACPI events or
> 	keyboard scancodes.

Why both an input and ACPI event?
With ACPI restricted to x86 only, wouldn't a more generic approach be desir=
ed?

> 	3) A rfkill.ko input handler module will be implemented, that listens to
> 	the SW_RFKILL and KEY_RFKILL events from all devices in the system, and
> 	will enable/disable radios on all 802.11 devices in the system.
>
> The above will make the RF-Kill button work under all real scenarios as
> user expects - it will enable/disable the radio. In the case where a
> user has an additional PCMCIA card, both the radios will be disabled by
> presing the RF-Kill button, which is arguably what the user expects.
> Even BlueTooth or other RF technologies (CDMA, EDGE) can hook into this
> mechanism.
>=20
> 	4) When userspace wants to take over the control over RF-Kill, and start
> 	additional services based on that, it can open the input devices to get
> 	the state of the buttons/switches, AND it can issue the EVIOCGRAB
> 	ioctl() to prevent the rfkill.ko and any other handlers from getting the
> 	events.
>
> This allows simple implementation of dbus notifications and
> NetworkManager-style configuration of network interfaces.
>=20

--nextPart1563790.ktngKqy3qG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEnDg5aqndE37Em0gRAp3zAJ9jD+MxBBJvIX6t1O91GB8jkxPQkgCg1Ghw
Vmm6yZsrRlTIeq/ZuaYtFoM=
=CEYL
-----END PGP SIGNATURE-----

--nextPart1563790.ktngKqy3qG--
