From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 17 Jan 2007 18:01:24 +0000
Message-ID: <1169056884.9175.66.camel@johannes.berg>
References: <20070116185524.GA5681@dmt>
	 <20070117141103.0e468bf4@griffin.suse.cz>
	 <1169046072.2750.10.camel@localhost.localdomain>
	 <1169047134.9175.49.camel@johannes.berg>
	 <1169055788.2550.44.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-o6LIjg/fqpGPwn2VP897"
Cc: Jiri Benc <jbenc@suse.cz>, Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:43581 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932564AbXAQSCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 13:02:05 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1169055788.2550.44.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-o6LIjg/fqpGPwn2VP897
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-01-17 at 12:43 -0500, Dan Williams wrote:

> I said "mostly" fullmac.  Sort of like ipw2100 (IIRC) is softmac but it
> does all the association stuff in firmware.  It doesn't fit fullmac, but
> it's a lot more fullmac than atheros.  There isn't any management frame
> processing, it doesn't do any data frame processing.

Right. I hadn't looked at data frames but suspected this is the case.

> The 8388 architecture is typical of a thick firmware architecture, where
> the firmware handles all 802.11 MAC management tasks.  The host driver
> downloads standard 802.3 frames to the firmware to be transmitted over
> the link as 802.11 frames.
>=20
> I thought these 2 things were essentially _the_ definition of fullmac,
> please correct me if I'm wrong.

Well we'll need more terms here. I had a short chat with Jouni and we
agree that what the Marvell card is doing is exposing the MLME
interface, and what d80211 is doing is implementing most of the MLME.

I guess the thing I'm saying is that exposing the MLME interface which
changes fairly frequently is a bad thing and I'd love to have firmware
that exposes lower level stuff like .

> Perhaps I just don't understand how flexible d80211 has become; when we
> last were talking about it 8 months ago, it appears that it could not
> handle parts that did significant pieces of work in firmware, like the
> 8388 does.  Do we have the functionality in d80211 yet to handle pieces
> that are a full mix of hybrid full/soft mac?

No, we don't have that yet, and we might never have. But I think I'm
starting to understand the issues at hand a bit better and it seems that
we'll need cfg80211 to be redefined.

> 1) What, if any of this, could actually fit into the d80211 stack, given
> the mostly fullmac operations of this part?=20

Can we rephrase this in terms of the MLME interface etc that the 802.11
standard speaks about? That'd be easier I think.

> 3) Could you enumerate your issues with the command dispatching?  Right
> now, many of the commands are blocking, which is suboptimal.  This is an
> artifact of the embedded history of the part.  We need to eventually fix
> that and make the upper layers not expect to block stuff like auth/assoc
> and scanning.  What other stuff are you thinking of?

Well, one thing is that the whole command processing goes through a
single function for no real benefit. You're basically saying
command(...,CMD_NUM,...) and in command() you do switch(cmd_num) and
multiplex it to a lot of functions again. I suppose I'd rather it called
the functions directly and those in turn called the little common code
there is in the dispatch routine.

johannes

--=-o6LIjg/fqpGPwn2VP897
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFrmR0/ETPhpq3jKURAgFNAKCYbgPtAYDjGp885gx1jUnps/JPNwCgr8f2
+D12yLhIsB1mbsnD+33CxzE=
=5Thf
-----END PGP SIGNATURE-----

--=-o6LIjg/fqpGPwn2VP897--

