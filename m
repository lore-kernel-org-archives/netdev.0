From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Thu, 18 Jan 2007 13:43:51 -0200
Message-ID: <20070118154351.GB3655@dmt>
References: <20070116185524.GA5681@dmt> <20070117141103.0e468bf4@griffin.suse.cz> <1169046072.2750.10.camel@localhost.localdomain> <1169047134.9175.49.camel@johannes.berg> <1169055788.2550.44.camel@localhost.localdomain> <20070117190726.13aaf245@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:43695 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753899AbYB0PAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 10:00:20 -0500
Content-Disposition: inline
In-Reply-To: <20070117190726.13aaf245@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Wed, Jan 17, 2007 at 07:07:26PM +0100, Jiri Benc wrote:
> On Wed, 17 Jan 2007 12:43:08 -0500, Dan Williams wrote:
> > The 8388 architecture is typical of a thick firmware architecture, where
> > the firmware handles all 802.11 MAC management tasks.  The host driver
> > downloads standard 802.3 frames to the firmware to be transmitted over
> > the link as 802.11 frames.
> 
> Ah. This isn't clear from the driver as it's too big to go through in
> detail. In particular, handing 802.3 frames to the firmware means you
> cannot use d80211 (nor ieee80211).
> 
> > I thought these 2 things were essentially _the_ definition of fullmac,
> > please correct me if I'm wrong.
> 
> I think you're right.
> 
> > Perhaps I just don't understand how flexible d80211 has become; when we
> > last were talking about it 8 months ago, it appears that it could not
> > handle parts that did significant pieces of work in firmware, like the
> > 8388 does.  Do we have the functionality in d80211 yet to handle pieces
> > that are a full mix of hybrid full/soft mac?
> 
> No.
> 
> > [...]
> > Not quite; the driver doesn't have to deal with the Open System
> > handshake or the Shared Key handshake.  Instead of Airo's 1-step
> > process, this is a simple 2-step process.  Look at wlan_join.c,
> > wlan_associate().  That's what happens; nothing more.
> 
> If everything is as simple as you wrote, why is the driver so
> incredibly big? It's almost impossible to review it in a reasonable
> time.

Most notably because the firmware provides a vast number of
configuration commands, and all of them are supported by the driver.

For instance, it supports sleep mode, which makes normal operation way
more complex than if it didnt (the driver queue's packets internally to
hand them out once the awake window has been opened).
