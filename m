From: Ben Hutchings <benh@debian.org>
Subject: Re: [PATCH] r8169: keep firmware in memory.
Date: Fri, 14 Jan 2011 16:30:35 +0000
Message-ID: <20110114163035.GY3702@decadent.org.uk>
References: <20110113230753.GA2750@electric-eye.fr.zoreil.com> <4D2FF29C.1050101@msgid.tls.msk.ru> <AANLkTikiGeSfae3guWRMp_hsh61JibacPpwGZVbgSy7h@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	David Woodhouse <dwmw2@infradead.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jarek =?utf-8?B?S2FtacWEc2tp?= <jarek@vilo.eu.org>,
	Hayes <hayeswang@realtek.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52283 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757972Ab1ANQbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 11:31:21 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTikiGeSfae3guWRMp_hsh61JibacPpwGZVbgSy7h@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 08:05:22AM -0800, Linus Torvalds wrote:
> [ background for new people in discussion: once more, a driver resume
> didn't get a working firmware load. ]
>=20
> On Thu, Jan 13, 2011 at 10:52 PM, Michael Tokarev <mjt@tls.msk.ru> wr=
ote:
> >
> > Given all this I think this is somewhat clumsy still. =A0How
> > does other NIC drivers handles this situation - e.g. tg3?
> > Maybe this needs to be a generic solution instead of per-driver?
>=20
> We've had this bug several times - and not just for network drivers
> either.
[...]
> Maybe the firmware loader could be made more useful to automatically
> handle the caching (it already knows about built-in firmware) for the
> case where CONFIG_PM is enabled. So that drivers _could_ just
> basically do "request_firmware()" in their resume functions, and it
> would get satisfied from RAM for the re-request case.
[...]
=20
This is something I started to implement, but never got finished.  I
don't think it can be done without an API change, though, as we need
to know when to drop firmware from the cache.  But perhaps this could
be done with a hook in the device-driver binding code.

Ben.

--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert =
Camus
