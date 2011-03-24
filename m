From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: can: c_can: TX delivery
Date: Thu, 24 Mar 2011 11:02:03 +0100
Message-ID: <4D8B169B.60401@pengutronix.de>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>    <20110323085340.GC346@e-circ.dyndns.org> <ff5ade24e148af2e46832e5a64444d05.squirrel@www2.linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1549A140E711BA075B74E3F3"
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>, bhupesh.sharma@st.com,
	wg@grandegger.com, b.spranger@linutronix.de, netdev@vger.kernel.org
To: Jan Altenberg <jan@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38570 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680Ab1CXKCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 06:02:15 -0400
In-Reply-To: <ff5ade24e148af2e46832e5a64444d05.squirrel@www2.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1549A140E711BA075B74E3F3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/23/2011 04:32 PM, Jan Altenberg wrote:
> Hi,
>=20
>> I split your 2 questions in 2 replies.
>=20
> Thanks :)
>=20
>> not sure if I made my point.  Note that this will eliminate the need
>> for explicit wrap-around.  It's done implicitely.
>=20
> Hmmm, I double-checked the datasheet, which gives the following stateme=
nt:
> "The receive/transmit priority for the Message Objects is attached to
> the message number.  Message Object 1 has the highest priority, while
> Message Object 32 has the lowest priority. If more than one
> transmission request is pending, they are serviced due to the priority
> of the corresponding Message Object."
>=20
> So, we shouldn't run into the scenario I described in my previous mail

ACK - the tx implementation is borrowed from the at91 driver. There we
have a prio field per mailbox (which is _not_ the CAN id), and the
mailbox number itself. If two mailboxes have the same prio the mailbox
with the lower number is send first. So we start with the highest prio
in mailbox 0, until the last mb, then decrease the prio and start with
mb 0. Special care is taken in prio wrap around and all mailboxes full.

Please recheck if this is implemented on the c_can driver correctly.

> and the existing implementation should be OK, right?!  I'm quite sure
> I've seen a situation where msg_obj 17 "seemed" to be pending, while
> msg_obj 18 and 19 already have been transmitted. But in that case, I
> enabled ONESHOT for the can interface, which enables the DA mode
> (automatic
> retransmission is disabled). The errata sheet for c_can covers that

Oh...Oneshot means if TX fails (due to higher prio frame on the bus) it
won't be tx'ed again. IIRC in the at91 there's a bit signalling that TX
has been aborted due to oneshot. Maybe an interrupt can be enabled, too.

Hmm....the driver advertised it supports oneshot mode. Has this been
tested? If oneshot isn't working we should disable it in the driver
until it has been fixed.

> mode. There's a problem with "Concurrent transmission requests" and I'm=

> quite sure my test-case hit that problem.
>=20
> I'm quite new to Bosch's c_can, so maybe Bhupesh can give some feedback=

> (or beat me for causing some confusion ;-)).

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig1549A140E711BA075B74E3F3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2LFp4ACgkQjTAFq1RaXHNsGwCeObZV+TEpHCEqNx9wbdzAxlxZ
eRkAnjmQORBFWUe4MxBZPRhGkdmLem7W
=HZ1Q
-----END PGP SIGNATURE-----

--------------enig1549A140E711BA075B74E3F3--
