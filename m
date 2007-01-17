From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 17 Jan 2007 15:18:54 +0000
Message-ID: <1169047134.9175.49.camel@johannes.berg>
References: <20070116185524.GA5681@dmt>
	 <20070117141103.0e468bf4@griffin.suse.cz>
	 <1169046072.2750.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GySeLrGhKOc+sBZe3WSF"
Cc: Jiri Benc <jbenc@suse.cz>, Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38208 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbXAQPTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 10:19:20 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1169046072.2750.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GySeLrGhKOc+sBZe3WSF
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-01-17 at 10:01 -0500, Dan Williams wrote:

> The part is a mostly fullmac part that until now has been targetted at
> the embedded market (PSP, N80 phone, etc).  That means that the driver
> shouldn't be too large (airo is about 8000 kLOC without airo_cs) but for
> some reason it still is; we're working on that.

I disagree that this is a fullmac part. You need to tell it to
authenticate and then you need to tell it to associate. IPW is a
fullmac, you tell it "use SSID xxx". Not this, you tell it "auth to
BSSID aaa" and then "associate to BSSID aaa" etc.

Besides the fact that I think this is a very dumb thing to do in new
hardware due to IEEE 802.11w (protected management frames) being well
underway which you can't handle at all that way, I also don't see how
you can claim that this is fullmac when you need to tell it every step
of the way.

The way I see it, you're telling the firmware to send an auth frame and
then you wait for the firmware to come back and tell you "yes I have
received a response" instead of just sending the frame yourself and then
waiting for the response frame. So the difference is that you need to do
a bit less frame parsing in the driver-stack.

I could drown you in technical comments on everything starting from the
way commands are sent, via the fact that there are large chunks of dead
code (#ifdef REASSOCIATION), down to the formatting of comments and
other trivialities, but I'd rather address the larger issues first.

johannes

--=-GySeLrGhKOc+sBZe3WSF
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFrj5e/ETPhpq3jKURAmvYAJ4tAAHbA2INxmrii39WvFqjUyiRQACgnZj+
SutXeVpJdyG+UDI5IvUfNwQ=
=aOuV
-----END PGP SIGNATURE-----

--=-GySeLrGhKOc+sBZe3WSF--

