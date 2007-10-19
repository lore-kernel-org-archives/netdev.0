From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] flush_work_sync vs. flush_scheduled_work Re: [PATCH]
	PHYLIB: IRQ event workqueue handling fixes
Date: Fri, 19 Oct 2007 10:00:45 +0200
Message-ID: <1192780845.15285.61.camel@johannes.berg>
References: <20071015125301.GC3015@ff.dom.local>
	 <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl>
	 <20071016062108.GB1000@ff.dom.local>
	 <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl>
	 <20071017085809.GA1658@ff.dom.local> <20071018063157.GA1694@ff.dom.local>
	 <20071018070531.GA2065@ff.dom.local>  <20071018154819.GA425@tv-sign.ru>
	 (sfid-20071018_164400_143342_215DD241)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-mf2LYc+CoHsF09ZpLPm5"
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:41200 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967210AbXJSH7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 03:59:52 -0400
In-Reply-To: <20071018154819.GA425@tv-sign.ru> (sfid-20071018_164400_143342_215DD241)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-mf2LYc+CoHsF09ZpLPm5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-10-18 at 19:48 +0400, Oleg Nesterov wrote:

> > +void flush_work_sync(struct work_struct *work)

> If we really the new helper, perhaps we can make it a bit better?
>=20
> 1. Modify insert_work() to take the "struct list_head *at" parameter inst=
ead
>    of "int tail". I think this patch will also cleanup the code a bit, an=
d
>    shrink a couple of bytes from .text
>=20
> 2. flush_work_sync() inserts a barrier right after this work and blocks.
>    We still need some retry logic to handle the queueing is in progress
>    of course, but we won't spin waiting for the other works.

3. Add lockdep annotation like the other API. :) Andrew just sent my
patch (used to be two patches by somebody's request but that's fine)
titled "workqueue: debug flushing deadlocks with lockdep" to Linus.

johannes

--=-mf2LYc+CoHsF09ZpLPm5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARxhkLKVg1VMiehFYAQINUQ/+LEr012kcOTShkwe6EJAGnDYrs7AHjZwx
PmL2FwQztWUWkInCrXAf5s8DQkD1oswmveiE5ZiqOPdp9Eg6qqv3112AX88LynPd
ZKLILC702lia6PIItDyeMaeEmfkgortobM6YlJAsk9E7z/IFzVep94eFWB5HD2rT
+zTOqvG5LI9hkIvtObqAYZ5b4MHSNzkN65NouEDc8Hwr/AV/uitFgc79IdLzXkwS
lvpVT9gw8/UuZQ2mqhMPBCMToAznsEiqH2xDrw5I6BUr9duGLZfyY3Kmqd3LCHTh
JKtFsRl19FlPYczclNSwc5q+1FX+IYYuZIuXAO8A6ijaHceuxud7XKif4vciu+wT
JJB1x69e5GgIl+JlDHmBdXp6BjoN21hTvW35uOd0wb86kB0FjrUOX7183ReQppC/
qTtKjXtMhOpcTz61z8wHAvxNSosfGmMsoAxUM1JVsQ6tQwLvOeOdovMo2vfmCa/o
GQhx6Fd7DpGKlBeadhd1gI3Hd2bu94Gvffsg1a+6BdjXuBfja5GNQiEDeSgTYf6c
3j11BaC0m0lYqMXLRdljyVU1cAAxeXHWGArXCuzp4BiWkhQ+nFX+/mbBZBwh9EEn
DRqEtYUQgfaBGnxJrHPYoBlXXYdX3/+pzz4hmsFNkmxAlTHbeWT9mSSIE3EmLxHU
AX7y8E8ba/0=
=M8Ey
-----END PGP SIGNATURE-----

--=-mf2LYc+CoHsF09ZpLPm5--

