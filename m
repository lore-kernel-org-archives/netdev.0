From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] zd1211rw-d80211: Use LED class
Date: Tue, 12 Dec 2006 18:26:34 -0500
Message-ID: <200612121826.38479.flamingice@sourmilk.net>
References: <200612110044.12205.flamingice@sourmilk.net> <200612112032.08646.flamingice@sourmilk.net> <20061212223835.GA8487@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5072988.LuYIfk2A59";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:12401 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932566AbWLLX5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 18:57:00 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061212223835.GA8487@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5072988.LuYIfk2A59
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 12 December 2006 17:38, Ulrich Kunitz wrote:
> Micheal, how resetting an LED every second is overkill is beyond
> me.
I mean it is overkill in that is more than needed.

> On a USB 2.0 port the available bandwidth is much higher than=20
> on the air. Notify also that the LED is flip-flopped on tx packets
> (which might include ACKs), so you simply don't know, when it
> becomes dark.
Ah, but if we transmit an ACK, we know because we receive a unicast frame. =
And=20
then we can rearm the TX LED reset timer. Any other cases?

> If nothing is transmitted the LED stays on, but if=20
> something is transmitted you might have to guess. That's the
> reason why I added the reset code. BTW the driver makes the LED
> blinks in a certain sequence (1s on, 2s off) while scanning. It is
> quite useful for debugging. You cannot do that without workqueues.
>
I don't think being able to flash pretty patterns while scanning is very=20
convincing reason to keep this. ;)

> > The upper layer does not know about the LEDs of individual devices. It
> > merely provides a number of LED triggers which device drivers can choose
> > to listen to - which sounds like what you're suggesting.
>
> No, this is not true. The upper layer has to support a Link-LED
> trigger. I believe that event triggers are a generic concept and
> should not be LED-specific. These triggers should inform about
> LINK status changes and the driver has to know, whether it has a
> LINK LED to switch or a LCD to display some information. There
> might be also other uses than for switching LEDs.
>
Yes, userspace can do that by listening for the SIOCGIWAP wireless event. L=
ED=20
triggers allow this to be done easily by default with no userspace=20
intervention. A link LED trigger would be added in addition to the usual=20
wireless event.

> > Switching to using LED class makes the housekeeping & workqueue code not
> > do anything useful, so I removed it. I am not against the housekeeping &
> > workqueue code - but right now this is dead code that will unnecessarily
> > cause zd1211rw-d80211 not to compile when wireless-dev gets the workque=
ue
> > api changes. (of course, d80211 doesn't compile either with the workque=
ue
> > changes, but I'm working out a patch for that..)
>
> No, it is not dead code as I explained.  Your patch is removing
> functionality and if I undestand right, might work in the future.
> But it is not tested and doesn't care for the activity
> flip-flopping.
>
It has been tested to the point where I can manually control the state of t=
he=20
LED from userspace via sysfs. I had to switch to using LED_OFF (or rather,=
=20
LED_DISABLED now) since the blinking behavior of LED_SCANNING made turning=
=20
off the LED not guaranteed. Turning off the link LED thus forces the activi=
ty=20
light off also, but that minor and can be easily fixed.

The activity flip flopping can be fixed as I mentioned further above, and I=
 do=20
intend to make this all work (eg. link LED trigger) as I need p54 to suppor=
t=20
blinking its LEDs. Do you really mind breaking the LED blinking for now? Ho=
w=20
many users are going to be affected while things are being sorted out?

If you really think the idea of LED classes and LED triggers is that=20
incredibly bad, I will drop this patch and just fix the workqueues. However=
,=20
as far as I can tell, it helps move policy out of the kernel while allowing=
=20
the most common use case to continue to work without userspace intervention.

=2DMichael Wu

--nextPart5072988.LuYIfk2A59
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFfzquT3Oqt9AH4aERAtX3AJ4ynNryv3RCvpXePBlbmGo3vWowiQCgmTfx
o7HWk7Wv1t5ZrAvLJO+2ofY=
=jx4D
-----END PGP SIGNATURE-----

--nextPart5072988.LuYIfk2A59--
