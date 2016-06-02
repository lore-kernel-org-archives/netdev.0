From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Thu, 2 Jun 2016 20:44:42 +0200
Message-ID: <201606022044.42420@pali>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com> <6d9575fd791c4e25b464b9a1b11daa83@ausx13mpc124.AMER.DELL.COM> <87vb1rwjql.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2437573.deOtVt4VIv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Mario_Limonciello@dell.com, gregkh@linuxfoundation.org,
	hayeswang@realtek.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	anthony.wong@canonical.com
To: =?utf-8?q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vb1rwjql.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2437573.deOtVt4VIv
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Thursday 02 June 2016 20:04:02 Bj=C3=B8rn Mork wrote:
> <Mario_Limonciello@Dell.com> writes:
> >> > 2) Track whether this is the first or second USB NIC plugged in.
> >> >  Only offer it
> >>=20
> >> on the first NIC detected by r8152.  When the second NIC is
> >> plugged in don't match from ACPI.
> >>=20
> >> > There would be a question of what to do if the first NIC is
> >> > removed and
> >>=20
> >> added back if it should get the persistent system MAC or not.
> >>=20
> >> > I'd say yes, just make sure that only one NIC can have it at a
> >> > time.
> >>=20
> >> You are going to get things very complex very quickly if you try
> >> to do this.
> >=20
> > It's really not that hard, track a module wide static variable
> > whether the feature is in use.  Track in each device whether the
> > feature was in use.  If it in use, don't assign the next device
> > plugged in via the ACPI string.  If a device is removed that has
> > the feature activated, change the module wide static variable.
>=20
> Having the mac address jump around in an arbitrary way like this is
> going to confuse the hell out of your users.  Consider what happens
> if the user docks a laptop with an r8152 usb dongle already plugged
> in... How are you going to explain that the dock gets some other mac
> address in this case? How are you going to explain the difference
> between using an r8152 based dongle and some other ethernet usb
> dongle with your systems?
>=20
> Make it behave consistently if you're going to add this.  Which can
> be done by specifically matching the Dell dock (doesn't it have an
> unique Dell device ID?) and ignoring any other r8152 device.  You
> could also choose to set the same mac for all r8152 devices.  Which
> is fine, but will probably confuse many users.
>=20
> What you definitely should not do is to change the mac for some
> arbitrary "first" device.  Then you are better off with the userspace
> proposal where you and your users have some chance to implement a
> sensible policy based on e.g. usb port numbers.

This is exactly what I wanted to write, but you were faster :-)

You can connect more Dell docks (with r8152 devices) and more non-Dell=20
r8152 devices in random order into Dell laptop. In any case dependent on=20
connect and disconnect order, devices always must have exactly same MAC=20
addresses. Otherwise there will be problems! It confuse users and also=20
admins of networks...

So if kernel approach is chosen then I think there are only two solution=20
those satisfy above conditions:

=46irst one is:
* all non-Dell devices have own MAC address
* all Dell devices have (one, same) AUX MAC address

Second one is:
* all devices (Dell and also non-Dell) have own address
* AUX MAC address is never used

So what do you (netdev maintainers) think about it?

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart2437573.deOtVt4VIv
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAldQfpoACgkQi/DJPQPkQ1JGBwCfd2dLVw7920L/rm54/k/YTyzQ
4O0AoJzlU5B+kj4T27FS4m+UDE6AEwZE
=owuf
-----END PGP SIGNATURE-----

--nextPart2437573.deOtVt4VIv--
