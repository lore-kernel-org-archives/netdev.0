From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Mon, 5 Dec 2016 13:14:42 +0100
Message-ID: <20161205121442.GD16126@amd>
References: <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd>
 <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>
 <20161202084511.GA32294@amd>
 <3192a4b6-1e97-048f-a0dd-bfc0f3d96ed8@st.com>
 <20161202123241.GA5869@amd>
 <c4748c8f-ae4b-9bbc-7d20-9c7b7ce433c8@st.com>
 <5db2ce3e-d4eb-d5d0-594c-8cd0f2e70476@st.com>
 <5627300c-a9b5-8709-bb08-5f0bceddfb05@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="DrWhICOqskFTAXiy"
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:43413 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbcLEMQf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 07:16:35 -0500
Content-Disposition: inline
In-Reply-To: <5627300c-a9b5-8709-bb08-5f0bceddfb05@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DrWhICOqskFTAXiy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> >Sorry but I'm a little bit confused. I'm dropped in some mails without
> >historic. I see cleanup, coalescence issue and TSO question.
> >What is your main issue? Are you working on gmac4 or 3.x ?
> >Can you refresh a little bit the story please ?
>=20
> let me try to do a sum, please Pavel feel free to correct me.
>=20
> There are some open points about the tx mitigation schema
> that we are trying to detail and eventually tune or change
> (but keeping the same performance on other user-case).
>=20
> In particular, the test case that is raising problem is
> an unicast tx bench.
> I suggested Pavel to tune coalesce (IC bit settings) via
> ethtool and monitor stats but he is getting problems (maybe
> due to lock).
>=20
> IIUC problems are mainly on new kernel and not on 4.4 where
> the gmac4 is missing. Please Pavel, could you confirm?

Actually no, it is the other way around. I can get 4.9 to work with
some tuning. 4.4 likes to crash when tx coalesce is enabled with
shorter than 40 msec timeout. (It crashes with default settings, too,
but that takes too long to reproduce.)

> Also there are some other discussion about the lock
> protection on NAPI still under discussion. I have not
> clear if in this case Pavel is getting strange behavior.

Yep, locking is broken in more than one place. I believe I understand
what some problems are. Let me prepare the patches.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--DrWhICOqskFTAXiy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhFWjIACgkQMOfwapXb+vIhAgCglzpCS2gzMqOS6GXg3Jshbv5x
jDAAn0WoTm4qLrIBsVp6/chFzbCNKOrJ
=TLF9
-----END PGP SIGNATURE-----

--DrWhICOqskFTAXiy--
