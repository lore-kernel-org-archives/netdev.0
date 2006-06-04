From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC PATCH 1/2] Hardware button support for Wireless cards: radiobtn
Date: Sun, 4 Jun 2006 13:44:27 +0200
Message-ID: <200606041344.31365.IvDoorn@gmail.com>
References: <200605251716.00742.IvDoorn@gmail.com> <200606041002.33696.IvDoorn@gmail.com> <200606041214.45999.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1902584.ht4tiDsxq0";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:33808 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932231AbWFDLl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 07:41:27 -0400
Received: by nf-out-0910.google.com with SMTP id c31so1625168nfb
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2006 04:41:26 -0700 (PDT)
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200606041214.45999.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1902584.ht4tiDsxq0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 4 June 2006 12:14, Stefan Rompf wrote:
> Am Sonntag 04 Juni 2006 10:02 schrieb Ivo van Doorn:
>=20
> > Except for the bluetooth radio key (which should be supported by the
> > radiobtn interface as well) the other buttons have support through alre=
ady
> > excisting input devices if I am correct.
>=20
> You are wrong for quite a bunch of laptop models. That's why I pointed yo=
u to=20
> the wistron_btns driver. Alternatively, look at the acerhk driver=20
> (http://www2.informatik.hu-berlin.de/~tauber/acerhk/). Many systems have =
a=20
> number of additional buttons that need to be handled by a special driver,=
 all=20
> sent to userspace, and just one of them to trigger the wireless card. Oth=
er=20
> models just handle the button in ACPI and generate an additional ACPI eve=
nt.

Ok, indeed a valid point.
Would it be better when the radio_button structure contains a list
of button structures each with its own poll function and current state.
And the radiobtn will loop through the list after each poll_delay time call=
ing
all poll functions. That way drivers can specify themselves which buttons n=
eed to be polled.

By renaming enable_radio and disable_radio in the radiobtn structure it cou=
ld
be made more generic for sending a certain event to the device and not only
an instruction for the radio.

> Looking at the RT2400-driver, I see what you want to accomplish: Take the=
 view=20
> of the WLAN card on the hardware controlled button enable/disable and=20
> generate events on it. However, in many cases it is another driver (see=20
> above) that sets or clears this state, and this should be the instance to=
=20
> send the input event.
>=20
> Note that I do not have objections against the driver being included in t=
he=20
> kernel - it just does not qualify as generic radiobutton support, but I k=
now=20
> it's hard to find a good name ;-)

Thats true. :)
Now lets see how this thing can be made a but more generic. ;)

> Looking at the code only: There should be an additional non-polling inter=
face=20
> for drivers that can generate events on the own.

Welll if the enable_radio and disable_radio are being renamed to a more
generic send_event for sending an event to the driver or something,
something similar can be done for the other way around I think, another han=
dler
to send an event from driver to radiobtn. But should such an event also tri=
gger
a call back to the driver, or should only the input event be triggered?

Ivo

--nextPart1902584.ht4tiDsxq0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEgsefaqndE37Em0gRAns9AJ9kjSnGQJUapMkGnwL+5c/wsYELdwCcDupR
r+D+73JywX2Zv5J9UbW2mlE=
=ucZ6
-----END PGP SIGNATURE-----

--nextPart1902584.ht4tiDsxq0--
