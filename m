From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Thu, 2 Jun 2016 21:03:25 +0200
Message-ID: <201606022103.25781@pali>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com> <87vb1rwjql.fsf@nemi.mork.no> <e94f28f69ee14610892125f67d9dae03@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3764370.2V1UJ9QrZi";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, hayeswang@realtek.com, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, anthony.wong@canonical.com
To: Mario_Limonciello@dell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e94f28f69ee14610892125f67d9dae03@ausx13mpc124.AMER.DELL.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3764370.2V1UJ9QrZi
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Thursday 02 June 2016 20:28:33 Mario_Limonciello@dell.com wrote:
> > -----Original Message-----
> > From: Bj=C3=B8rn Mork [mailto:bjorn@mork.no]
> > Sent: Thursday, June 2, 2016 1:04 PM
> > To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> > Cc: gregkh@linuxfoundation.org; hayeswang@realtek.com; linux-
> > kernel@vger.kernel.org; netdev@vger.kernel.org; linux-
> > usb@vger.kernel.org; pali.rohar@gmail.com;
> > anthony.wong@canonical.com Subject: Re: [PATCH] r8152: Add support
> > for setting MAC to system's Auxiliary MAC address
> >=20
> > <Mario_Limonciello@Dell.com> writes:
> > >> > 2) Track whether this is the first or second USB NIC plugged
> > >> > in.  Only
> >=20
> > offer it
> >=20
> > >> on the first NIC detected by r8152.  When the second NIC is
> > >> plugged in
> >=20
> > don't
> >=20
> > >> match from ACPI.
> > >>=20
> > >> > There would be a question of what to do if the first NIC is
> > >> > removed and
> > >>=20
> > >> added back if it should get the persistent system MAC or not.
> > >>=20
> > >> > I'd say yes, just make sure that only one NIC can have it at a
> > >> > time.
> > >>=20
> > >> You are going to get things very complex very quickly if you try
> > >> to do this.
> > >=20
> > > It's really not that hard, track a module wide static variable
> > > whether the feature is in use.  Track in each device whether the
> > > feature was in use.  If it in use, don't assign the next device
> > > plugged in via the ACPI string.  If a device is removed that has
> > > the feature activated, change the module wide static variable.
> >=20
> > Having the mac address jump around in an arbitrary way like this is
> > going to confuse the hell out of your users.  Consider what happens
> > if the user docks a laptop with an r8152 usb dongle already
> > plugged in... How are you going to explain that the dock gets some
> > other mac address in this case? How are you going to explain the
> > difference between using an r8152 based dongle and some other
> > ethernet usb dongle with your systems?
>=20
> Yeah I understand the concern.  I agree that would be very confusing
> to a user.  This does need to match only on Dell docks then.
>=20
> > Make it behave consistently if you're going to add this.  Which can
> > be done by specifically matching the Dell dock (doesn't it have an
> > unique Dell device ID?) and ignoring any other r8152 device.  You
> > could also choose to set the same mac for all r8152 devices.=20
> > Which is fine, but will probably confuse many users.
>=20
> Unfortunately there is no Dell specific VID/PID.  I checked a no-name
> dongle that used r8152 and it was the same (0bda:8153).  Maybe Hayes
> Wang can check with his Windows driver colleagues if there was
> anything else to key off when this was implemented on the Windows
> Realtek driver.  If there is something else to key off of, I'm not
> aware what it is.  I'll check with some of my colleagues too.

I have some other questions which answers should we know:

1) Is that AUX MAC address implemented only in customized windows Dell=20
driver? Or also in "upstream" windows Realtek driver and all users of=20
Realtek hw can install it (or update via next driver update)?

2) Can you share pseudo code or description of algorithm which decide=20
MAC address for newly connected r8152 device on windows? This could help=20
us to decide if something similar/same cannot be implemented also on=20
linux (either in kernel or userspace). What I would like to know are=20
those situations when you connect more r8152 devices (some Dell and some=20
non-Dell).

> I do have a way to query if a dock is plugged in via SMM, but I doubt
> that's what Realtek is using on the Windows side.

So there is some way to check if Dell dock is plugged, right? But what=20
happen if you connect Dell dock and also non-Dell r8152 device? Can you=20
distinguish which device is Dell and which non-Dell?

Anyway, I think that by SMM you mean dell smbios API call. Cannot you=20
guys in Dell release documentation of all smbios calls to community?=20
Time to time you release some small parts in libsmbios project which=20
then we can use for implementing useful parts in kernel (e.g. LED driver=20
for controlling keyboard backlight). But there are couple of=20
undocumented APIs and maybe some can also help with this problem...=20

> I'd leave that as
> a second to last resort (last resort being move back to userspace
> again).
>=20
> > What you definitely should not do is to change the mac for some
> > arbitrary "first" device.  Then you are better off with the
> > userspace proposal where you and your users have some chance to
> > implement a sensible policy based on e.g. usb port numbers.
>=20
> OK, if I can't come up with a way to key on the device being a Dell
> dock I'll scrap this entirely kernel approach.

E.g. PCI devices have ordinary PCI device & vendor IDs, but have Dell=20
specific subsystem IDs. And via subsystem IDs we can distinguish between=20
Intel graphics card on Dell laptop and on non-Dell laptop.

Does not you have some special/modified firmware in those Dell realtek=20
docks (and ability to check from OS some registers)?

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart3764370.2V1UJ9QrZi
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAldQgv0ACgkQi/DJPQPkQ1JICwCeJYeAy+Lr6BXi+n5adfKurgBW
5XUAn0d9j23UIdK33R6fInHGCZOFkZoE
=ty4I
-----END PGP SIGNATURE-----

--nextPart3764370.2V1UJ9QrZi--
