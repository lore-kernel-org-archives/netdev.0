From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Mon, 22 Jan 2007 09:26:13 -0200
Message-ID: <20070122112613.GA3038@dmt>
References: <20070116185524.GA5681@dmt> <20070117141103.0e468bf4@griffin.suse.cz> <1169046072.2750.10.camel@localhost.localdomain> <1169047134.9175.49.camel@johannes.berg> <1169055788.2550.44.camel@localhost.localdomain> <1169056884.9175.66.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, Jiri Benc <jbenc@suse.cz>,
	Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:56772 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751673AbXAVLbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 06:31:09 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1169056884.9175.66.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 17, 2007 at 06:01:24PM +0000, Johannes Berg wrote:
> On Wed, 2007-01-17 at 12:43 -0500, Dan Williams wrote:
> 
> > I said "mostly" fullmac.  Sort of like ipw2100 (IIRC) is softmac but it
> > does all the association stuff in firmware.  It doesn't fit fullmac, but
> > it's a lot more fullmac than atheros.  There isn't any management frame
> > processing, it doesn't do any data frame processing.
> 
> Right. I hadn't looked at data frames but suspected this is the case.
> 
> > The 8388 architecture is typical of a thick firmware architecture, where
> > the firmware handles all 802.11 MAC management tasks.  The host driver
> > downloads standard 802.3 frames to the firmware to be transmitted over
> > the link as 802.11 frames.
> > 
> > I thought these 2 things were essentially _the_ definition of fullmac,
> > please correct me if I'm wrong.
> 
> Well we'll need more terms here. I had a short chat with Jouni and we
> agree that what the Marvell card is doing is exposing the MLME
> interface, and what d80211 is doing is implementing most of the MLME.
> 
> I guess the thing I'm saying is that exposing the MLME interface which
> changes fairly frequently is a bad thing and I'd love to have firmware
> that exposes lower level stuff like .
> 
> > Perhaps I just don't understand how flexible d80211 has become; when we
> > last were talking about it 8 months ago, it appears that it could not
> > handle parts that did significant pieces of work in firmware, like the
> > 8388 does.  Do we have the functionality in d80211 yet to handle pieces
> > that are a full mix of hybrid full/soft mac?
> 
> No, we don't have that yet, and we might never have. But I think I'm
> starting to understand the issues at hand a bit better and it seems that
> we'll need cfg80211 to be redefined.

So using the d80211 stack is completly out of question?

Another detail is the way we deal with mesh networking: a separate
device "mshX" is created, and that certainly does not fit d80211?

