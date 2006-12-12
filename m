From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] zd1211rw-d80211: Use LED class
Date: Mon, 11 Dec 2006 20:32:03 -0500
Message-ID: <200612112032.08646.flamingice@sourmilk.net>
References: <200612110044.12205.flamingice@sourmilk.net> <20061211225538.GA30512@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3063642.iEmXvfzts7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:23115 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750835AbWLLBc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 20:32:29 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061211225538.GA30512@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3063642.iEmXvfzts7
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 11 December 2006 17:55, Ulrich Kunitz wrote:
> I cannot accknowledge this patch. Michael, the LED does not only
> show the link status, but also indicate that packets are sent,
> which is done by the firmware. However the LED flags have to be
> reset every second, because if an odd number of packets have been
> transmitted, the LED stays dark.
The d80211 TX trigger has the same behavior. It's probably worse on single =
LED=20
devices since it may look like nothing is on. Even then, I think having it=
=20
reset every second is overkill. Having an "TX LED" watchdog run when we=20
haven't TXed anything for the last second or sounds better to me. This woul=
d=20
force the LEDs to a reasonable state when we know nothing has been TXed=20
recently. This could be for STA mode only.. I dunno if the LED blinks when=
=20
sending hardware generated/filled beacons.

> I even don't think, that the upper d80211 layers should care for
> LED controlling. The LEDs are part of the device and should be
> controlled by the device driver. I have a ZD1211 device, which has
> two LEDs. Now suddenly the upper layer must know about the two
> LEDs. But there could be WLAN devices who would have 6 LEDs for
> whatever reason. Should the upper layer know about all those LEDs
> and their semantics? The better design would be, that the driver
> could register for upper layer events and control it's LEDs
> accordingly.
>
The upper layer does not know about the LEDs of individual devices. It mere=
ly=20
provides a number of LED triggers which device drivers can choose to listen=
=20
to - which sounds like what you're suggesting.

> If you would also have taken the time to look at my out-of-tree
> driver, you would have seen the other housekeeping/workqueue
> functions for handling strong signals. These changes are still
> missing from the kernel, because I have still to resolve issues
> with AL2230 RFs. This again can only be implemented in workqueues,
> because the register accesses require process context.
>
Switching to using LED class makes the housekeeping & workqueue code not do=
=20
anything useful, so I removed it. I am not against the housekeeping &=20
workqueue code - but right now this is dead code that will unnecessarily=20
cause zd1211rw-d80211 not to compile when wireless-dev gets the workqueue a=
pi=20
changes. (of course, d80211 doesn't compile either with the workqueue=20
changes, but I'm working out a patch for that..)

If you are testing your new RF code with zd1211rw-d80211 also, I can add th=
e=20
workqueue & housekeeping code back as soon as things are sorted out in=20
wireless-dev. I will also probably port the rts/cts code after wireless-dev=
=20
deals with the workqueue changes.

Sound tolerable to you?

=2DMichael Wu

--nextPart3063642.iEmXvfzts7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFfgaYT3Oqt9AH4aERAhUWAJ4l5bu6ZipVSvAjLqjuprnIA8jpWQCgpDao
mk6nV83DuoPqb0ynBPUda4o=
=OLXQ
-----END PGP SIGNATURE-----

--nextPart3063642.iEmXvfzts7--
