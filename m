From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Tue, 17 Mar 2009 20:22:22 +0100
Message-ID: <1237317742.31814.28.camel@johannes.local>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com>
	 <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>
	 <1237140665.24621.2.camel@johannes.local>
	 <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
	 <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 (sfid-20090316_142417_625321_EAE390ED)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-APmAsfgopLNAwlSHx71g"
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Jeff Chua <jeff.chua.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52230 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756933AbZCQV1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:27:33 -0400
In-Reply-To: <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com> (sfid-20090316_142417_625321_EAE390ED)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-APmAsfgopLNAwlSHx71g
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-03-16 at 21:24 +0800, Jeff Chua wrote:

> Here's what I did, and it's repeatable.
>=20
> Take the attached bisect log and replay it, and the last offending
> commit is this ...
> # git log
> commit 71c11fb57b924c160297ccd9e1761db598d00ac2
> Author: Johannes Berg <johannes@sipsolutions.net>
> Date:   Tue Oct 28 18:29:48 2008 +0100
>=20
>     b43/legacy: remove SSID code
>=20
> Yes, this is not the real problem, but it's the last commit that cause
> the problem, and I couldn't bisect further, typing the next "git
> bisect bad" and the commit is

I'm on 0191b62 now and cannot reproduce the problem with iwlwifi
hardware and a linksys (broadcom-based) AP with hidden SSID.

> Anything I can help to debug further, just let me know.

Compile iwlwifi with debugging please, and instead of plain modprobe
iwlagn, do this:
	modprobe iwlagn debug=3D0x800 debug50=3D0x800

Then send me the relevant dmesg output from a working and a failed
attempt. You should see something like this

[  318.420537] ieee80211 phy4: U iwl_bg_request_scan Start direct scan for =
'myssid'

in the log. I can't see any reason why it would be missing. For me, the
association is instantaneous after saying "ap any". This is expected
too, because
	iwconfig wlan0 essid "myessid"
will have triggered a directed scan for the AP.

There are two possible failure scenarios that I can imagine:

1) You see no line like the one above in your log, but rather

[  736.047879] ieee80211 phy5: U iwl_bg_request_scan Start indirect scan.

This would indicate a bug in the driver.


2) You do see the line with the SSID, but you don't get any reply. In
this case, please try doing it manually:
	iwlist wlan0 scan essid 'myssid'
Wait about 15 seconds between each attempt of doing so, and report
whether your AP is listed in the results or not. If it isn't most of the
time, then your AP is broken.

johannes

--=-APmAsfgopLNAwlSHx71g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJv/hrAAoJEKVg1VMiehFYEnQP/0L8NEZmyYZMIzDTl7A1/YIk
GnLVkUEsIQd4WtRQXyiYnw9OHUaG78oqfdCUJqA2AiPiL5jXrp1IMqNyZAI8IRm4
OzfWVdXYeYc0RoJzksrZOTS2UYG38Hv/XltM77cWOCLfi6aAAZ7lkyPNnjDJtSqd
3mDzjpbzVRnJYT17aSJhEAJvxygzpT0p8B0lJOKWepyivQhSz28ie50cHsfAxvjr
tM8eVsH6jW6ZN8+AIiluScRws20YIwOwJEFv43Uapnl4QwvB6Vp2RIVfSx4jNLq1
uzQ3NHjur6EbpKtUS3HYk7hYSurXb3XDgtolY1WxzePSY/i+RHiColMFfFoN0EZA
6kam7Pfjml8Xtoz2l+vNL4G+hHvIpVC/rCz7upxsayvt+q0i/jPkC+ThIdKp1gKZ
iT7D0qxEKac+Z1SDUYVY999H67jM66nrwpro+RSJdb4oQCWEEj5Hxa/UHtYElLxh
bdmM2N1GUo+cKuX/GtOfXo5WnzIxduhozMRDudtVFAjc0IRfMl4kVHxzL3WPQ691
qHRg8kNgrLqStJZQ49x9sjoE2TgFW5r7K6EUhrM1upRJqtgn2c4BAU2UgHMugUU9
whAwhCnwSlWV+LnQYqpXzXmUAZSANqeB0d5tS2mLZ3w1UXM1T7+IhpRWQoBSQoAE
K3tbYQQV1Xd7fUI648I/
=95ZB
-----END PGP SIGNATURE-----

--=-APmAsfgopLNAwlSHx71g--

