From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] b44-ssb: Fix the SSB dependency hell
Date: Sat, 11 Aug 2007 02:57:36 +0200
Message-ID: <1186793856.4862.16.camel@johannes.berg>
References: <200708110208.21624.mb@bu3sch.de>
	 <20070811004341.GA22213@stusta.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+WX+wiHefmFHqmVLS8Om"
Cc: Michael Buesch <mb@bu3sch.de>,
	John Linville <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59654 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759593AbXHKAzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 20:55:16 -0400
In-Reply-To: <20070811004341.GA22213@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+WX+wiHefmFHqmVLS8Om
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-08-11 at 02:43 +0200, Adrian Bunk wrote:

> -ENOMENUCONFIGPATCH

Has anybody decided how it could possibly even look like anyhow? It
should be fixed, but nobody has a plan.

> That's horrible - you shouldn't force the user to manually enable three=20
> options.

Well, akpm says: "select is broken. do not ever use it"


> config SSB_PCIHOST_POSSIBLE
[...]

> 	depends on SSB_PCIHOST_POSSIBLE
> 	select SSB
> 	select SSB_PCIHOST

That would, indeed, be possible. But it's ... ugly ... you've now
effectively pushed the information on what *SSB* depends on into each
SSB *user* instead of SSB itself...

> Is there any extremely good reason why options like SSB or SSB_PCIHOST=20
> have to be user visible?=20

Yes. Embedded systems like the small Linksys routers come with SSB as
the system bus. No PCI/PCIHOST.

> And according to the kconfig help text, we should remove the B44_PCI=20
> option and enable the code unconditionally?
> (Or what was the person writing this help text smoking^Wthinking when
>  writing it?)

Same reason. They have a b44 core there but no pci.

johannes

--=-+WX+wiHefmFHqmVLS8Om
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGvQmA/ETPhpq3jKURAhp6AKCsbN2y9kmK2yGzlcKOOuL2gPcgTQCfe6tD
kocTHtATcTJDo/1PVf5HK9Q=
=G8st
-----END PGP SIGNATURE-----

--=-+WX+wiHefmFHqmVLS8Om--

