From: Stuffed Crust <pizza@shaftnet.org>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Mon, 4 Sep 2006 10:13:28 -0400
Message-ID: <20060904141328.GA19295@shaftnet.org>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157093640.2878.26.camel@ux156> <20060901163558.GB13815@bougret.hpl.hp.com> <200609012055.48799.mb@bu3sch.de> <20060901221045.GB13975@bougret.hpl.hp.com> <1157358909.3324.42.camel@ux156>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="M9NhX3UHpAaciwkO"
Cc: jt@hpl.hp.com, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-73-230-86.se.biz.rr.com ([24.73.230.86]:36567 "EHLO
	shaft.shaftnet.org") by vger.kernel.org with ESMTP id S1750873AbWIDOMd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 10:12:33 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1157358909.3324.42.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 04, 2006 at 10:35:09AM +0200, Johannes Berg wrote:
> wireless.c and driver WE support in its current form must die.

I doubt you'll have anyone argue this point; not even JT.  I doubt he=20
cares how WE is ultimately implemented, only that things continue=20
to "just work".

The problems you've just enumerated with WE aren't actually the fault of
WE per se, but rather an internal kernel API problem -- Wireless drivers
currently handle the WE ioctls directly, and thus all have their own
quirks. (Or as you put it, a userspace API dictated internal APIs.  It=20
may have been GoodEnough(tm) then, but it isn't any longer, eh?)

While a new userspace API will eventually open up more possibilities,
the real benefit of d80211/nl80211 is its middle/thunk layer, simplifying
driver development considerably through its shared code (and 802.11
stack), and generally enforcing a separation of userspace from device
drivers and the current mess that's a result.  But then you already
explained all of this (and I completely agree with your enumeration of
the benefits)

I won't shed any tears to see WE (the userspace API) superceded (as long
as its replacement is genuinely better rather than simply different) and
I'll dance for joy when the internal wireless APIs get replaced and
wireless drivers no longer directly interact with userspace -- but keep
in mind that these are two independent scenarios.

Treat WE as a userspace API, not an internal API.  From d80211/nl80211's
perspective, the code necessary to support the latest WE-21 proposal is
trivial[1], and in the mean time, WE-21 fixes several real, current
problems that affect users *now*, necessitating a solution *now*.

Meanwhile.

I look at this and can't but help think about ALSA.  How long did it
take to get ALSA merged into the kernel, despite it being that much
MoreBetter(tm) than the in-kernel OSSFree drivers/APIs, each with their
own userspace interactions and thus behaivoral quirks and bugs?  And how
many in-kernel OSS drivers still remain because of problems with (or
missing) ALSA drivers?  (And how many quirks still remain with the=20
alsa-oss emulation?)

 - Solomon

[1] Generic WE support is 2K/37K [mid-layer] lines in one of the=20
    codebases I maintain, and that includes full compatibility with=20
    WE-8 through WE-21.
--=20
Solomon Peachy        		       pizza at shaftnet dot org	=20
Melbourne, FL                          ^^ (mail/jabber/gtalk) ^^
Quidquid latine dictum sit, altum viditur.          ICQ: 1318344


--M9NhX3UHpAaciwkO
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.7 (GNU/Linux)

iD8DBQFE/DSIPuLgii2759ARAnS0AKCSDzCYfJk2j+qTEgqhlZCp+3O0UwCg6f1K
R4Qqv4UMIfgeit4hfLIV0kU=
=1mmi
-----END PGP SIGNATURE-----

--M9NhX3UHpAaciwkO--
