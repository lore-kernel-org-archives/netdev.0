From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: ieee80211_set_encryption...
Date: Mon, 14 Aug 2006 08:53:19 -0700
Message-ID: <20060814155319.GB1196@instant802.com>
References: <44E02F41.2060300@sipsolutions.net> <44E03175.6070804@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-34.dex002.intermedia.net ([64.78.21.119]:48432 "EHLO
	dhost002-34.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751459AbWHNPxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 11:53:24 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <44E03175.6070804@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2006 at 10:16:53AM +0200, Johannes Berg wrote:
> ... is a big mess.

Yes, and so is the number of different ways this has been implemented in
hardware designs..

> What's with all the comments saying 'maybe with blabla hardware that can 
> be done in hw but disable here now' etc? Can't we just have a 'please 
> decide' callback in the driver that tells us whether this can be done in 
> hw or sw?

For some cases yes, but it is a bit difficult to come up with a generic
model that would work for everything. Supporting multiple BSSes in AP
mode makes some quite complex cases.

> Or how about no_tkip_wmm_hwaccel? That seems pretty weird too.

That's needed to allow TKIP hwaccel to be used for non-WMM case while
falling back to software for WMM. This is needed to workaround some
hardware issues. Sure, this could be hidden in the hardware driver, but
I would prefer to allow the 802.11 stack support software
encryption/decryption to keep the low-level drivers simpler (and to
avoid their authors from doing some silly copy-paste things with
encryption).

> I do realize that key management in the face of wpa2 and similar is 
> difficult, but this seems overly complex. Comments?

WPA2 is not the complex part; adding WMM into the picture with some
hardware design was and multi-BSS support adds quite a bit more
complexity here.

-- 
Jouni Malinen                                            PGP id EFC895FA
