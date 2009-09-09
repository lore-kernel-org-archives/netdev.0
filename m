From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: Re: [PATCH] ath5k: do not free irq after resume when card has been
	removed
Date: Wed, 9 Sep 2009 14:50:06 -0300
Message-ID: <20090909175006.GA7945@vespa.holoscopio.com>
References: <1252457551-4909-1-git-send-email-cascardo@holoscopio.com> <20090909033237.GC13550@hash.localnet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FL5UXtIhxfXey3p5"
Cc: ath5k-devel@lists.ath5k.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lrodriguez@atheros.com, mickflemm@gmail.com, jirislaby@gmail.com,
	linville@tuxdriver.com, johannes@sipsolutions.net
To: Bob Copeland <me@bobcopeland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from liberdade.minaslivre.org ([72.232.18.203]:33170 "EHLO
	liberdade.minaslivre.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbZIIRuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 13:50:07 -0400
Content-Disposition: inline
In-Reply-To: <20090909033237.GC13550@hash.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 08, 2009 at 11:32:37PM -0400, Bob Copeland wrote:
> On Tue, Sep 08, 2009 at 09:52:31PM -0300, Thadeu Lima de Souza Cascardo w=
rote:
> > ath5k will try to request irq when resuming and fails if the device
> > (like a PCMCIA card) has been removed.
>=20
> That's not true, ath5k no longer requests an irq when resuming.
>=20

I've just saw there's a commit by you in the next tree that just removes
the irq requesting and releasing in resume/suspend functions.

> > This solves this issue defining a new flag for the status bitmap to
> > indicate when irq has been successfully requested and does not try to
> > release it if not.
>=20
> I'd rather not fix it with a status bit.  What kernel is this against?
>=20

This is against v2.6.31-rc9, so I get a warning with a version that's
about to get stable. Sorry I am late in the release cycle.

I've used a status bit because the drivers I took a look at did
release/request irq in suspend/resume. I couldn't find a message about
not doing it was the right thing which I thought I saw in the latest
updates to v2.6.31-rcX. I guess it was something just like your commit
which I did see some weeks ago.

Since this is warning, is this worth backporting to rc?

> --=20
> Bob Copeland %% www.bobcopeland.com
>=20

Regards,
Cascardo.

--FL5UXtIhxfXey3p5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqn6s4ACgkQyTpryRcqtS3r7ACggq2iFrVoYpQdP2BEPEYEyML/
gxoAnj5GftdMAESCK2EoNVe5a4FmYxYE
=wJs1
-----END PGP SIGNATURE-----

--FL5UXtIhxfXey3p5--
