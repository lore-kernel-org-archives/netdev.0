From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Tue, 06 Jan 2015 09:23:37 +0100
Message-ID: <1420532617.1966.2.camel@sipsolutions.net>
References: <1420297188.2397.3.camel@tiscali.nl>
	 <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>
	 <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com>
	 <1420324124.9624.60.camel@x220> <54AA641C.7050307@broadcom.com>
	 <1420479510.14308.23.camel@x220>
	 (sfid-20150105_183907_807502_81C08416) <1420484224.9459.16.camel@sipsolutions.net>
	 <1420495519.14308.29.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Jiri Kosina <jkosina@suse.cz>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420495519.14308.29.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-01-05 at 23:05 +0100, Paul Bolle wrote:
> On Mon, 2015-01-05 at 19:57 +0100, Johannes Berg wrote:
> > Multiple other groups of ioctls could be converted in similar patches,
> > until at the end you can completely remove ipw_wx_handlers and rely
> > entirely on cfg80211's wext compatibility.
> > 
> > So far the theory - in practice nobody cared enough to start working on
> > any of these drivers, let alone actually has the hardware today.
> 
> So my suggestion to make ipw2200 no longer use cfg80211_wext_giwname()
> would actually be backwards. What's actually needed, in theory, is to
> use more of what's provided under CFG80211_WEXT (and, I guess, less of
> what's provided under WIRELESS_EXT). Did I get that right?

Yes, though I'd argue there are multiple levels of truth here.

Yours is the theoretical, hopefully-forward-looking one where we still
expect the driver to actually be modified to take advantage of the new
frameworks (which is independent of wext support towards userspace). In
that scenario, yes, it should use more until it uses all, and then it
can stop concerning itself with wext (which would be a win because
driver/wext interaction is always finicky) (*)

Then there's the other level that you were looking at earlier - simply
removing all of this again from this driver because nobody is going to
work on it. That'd actually make sense and shrink the driver footprint
(no need to load cfg80211 for using almost nothing of it) but this is no
longer feasible since it would again break userspace API - as I said you
can today discover the presence of this device/driver with nl80211 -
that would be broken by removing cfg80211 from here.

And then there's the practical third version that's likely to happen -
i.e. nothing :-)

johannes

(*) FWIW, if done to all drivers it would allow shrinking cfg80211-wext
by a lot because all the EXPORT_SYMBOL would no longer be needed - but
come to think of it we can fix that differently.
