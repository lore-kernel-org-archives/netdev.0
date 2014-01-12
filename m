From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/3] b43: Fix oops if firmware is not available
Date: Sun, 12 Jan 2014 04:24:07 +0000
Message-ID: <1389500647.3720.51.camel@deadeye.wl.decadent.org.uk>
References: <1389469714-13040-1-git-send-email-Larry.Finger@lwfinger.net>
		 <1389469714-13040-3-git-send-email-Larry.Finger@lwfinger.net>
	 <1389497251.3720.40.camel@deadeye.wl.decadent.org.uk>
	 <52D21226.4070306@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AjZGN/7EuVBP0FVQPOrk"
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39583 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750958AbaALEYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 23:24:25 -0500
In-Reply-To: <52D21226.4070306@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AjZGN/7EuVBP0FVQPOrk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-01-11 at 21:55 -0600, Larry Finger wrote:
> On 01/11/2014 09:27 PM, Ben Hutchings wrote:
> > On Sat, 2014-01-11 at 13:48 -0600, Larry Finger wrote:
> >> On openSUSE systems, the script that installs the firmware for b43 als=
o
> >> unloads and reloads the driver. When the firmware was not previously
> >> available, the driver has stalled at a wait_for_completion(). When the
> >> unload routine releases that hold, the driver encounters structures
> >> that have already been deleted and generates a fatal condition. When
> >> the user does a manual restart, the file system cleanup frequently
> >> results in the firmware files being deleted and the user is never able
> >> to install the firmware. The fix is to change the wait_for_completion(=
)
> >> with a wait_for_completion_timeout() with a 60 second wait period.
> >>
> >> There is a potential race condition; however, the chances that less
> >> than a minute has elapsed between the initial driver load and a
> >> subsequent unload is very unlikely.
> >
> > A minute-long race is 'unlikely' to be hit?  Seriously?!
>=20
> Ben,
>=20
> If you force a reboot before the minute expires, nothing weird happens. T=
he only=20
> race condition happens when the user has to

...remove the module.  Exactly how the bug reporter triggered module
removal seems irrelevant.

> log in, open a terminal, run a=20
> script that downloads 13.5 MiB of files from the Internet, and then execu=
tes the=20
> firmware extraction program. On my 10 Mbps external line and a 2 GHz CPU,=
 that=20
> takes 32 s, plus any time to enter the password for a sudo operation. Tha=
t was=20
> the basis for my conclusion that a race is unlikely.
>=20
> What is the minimum time that should be allowed for a request_firmware_no=
wait()=20
> to respond? I know we had to go to asynchronous fw loading because the=
=20
> synchronous  version would timeout at 30 s.

You could switch back to synchronous firmware loading soon, as it's not
going to support a usermode helper any more.

But until then, the proper fix for this is going to be to cancel the
waiter earlier in teardown.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-AjZGN/7EuVBP0FVQPOrk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUtIY5+e/yOyVhhEJAQrOQQ/9E86PPU8EKcXWSzY/zA+uJutO6AuhVWf4
1dDD+0GO2PdHTZA0Z0k1sFCq1knB+p9oX4VZWiPIPCatJX/L0s5POpGSFi6lcYKz
4a3RdSVhtvLa7Q7T5MIi7DUXT2i1zlPi8T+dr+5WoUAGyin8vWJeWYaBdroRRWGb
pT6q7RjE01l1K1aZB+JuYLLMkPZBXX18NjtlwBk//gYvCkFd+kgFGuWN4INbviXj
TwWQgB3OjsyWhIvhdBhVmj+l7yOtEYAYWTpMQeMWQ9OYqElZbrrEdO34TdGBzY/l
hHcrsLaZpmVmve6OsF6gKIzTdW7u/GrNrUqD8uWGo1OPc6VCMEjtsR7JikKGwSZ5
A7R39hDxASInKBTSUF3CKgBy2vz4CbRcY6lbhx3XSkevCDJcHngY5vPSTZfSlsb6
xhXWiBHCPVoRE+SFnEhCgJFPhZW//NJjdnQG84WEFC+/3fEsKE8z+r6islt6e/Xy
BYsQHiPi+S25E9ZXSXtxZw5/OeDgJi6Z1vvbB3SR4mItdPxAWNGM/RX+w+znzhfH
Y48uwuB0xb2+dtSxTrtQ3wxXfFib8B16QjmkowfcVbIMFF82FAUc8jCF2IMAM3wq
CtbPbXcZb2IWzDC+kQBz/Us+VoOb5gTEjT7Tib0RCzb/CCxSnVWrwbWsUCBfnuTO
TeoTL/DgpvU=
=X3j3
-----END PGP SIGNATURE-----

--=-AjZGN/7EuVBP0FVQPOrk--
