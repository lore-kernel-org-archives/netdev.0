From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 17 Jan 2007 19:07:26 +0100
Message-ID: <20070117190726.13aaf245@griffin.suse.cz>
References: <20070116185524.GA5681@dmt>
	<20070117141103.0e468bf4@griffin.suse.cz>
	<1169046072.2750.10.camel@localhost.localdomain>
	<1169047134.9175.49.camel@johannes.berg>
	<1169055788.2550.44.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:60393 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932614AbXAQSHd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 13:07:33 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1169055788.2550.44.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Jan 2007 12:43:08 -0500, Dan Williams wrote:
> The 8388 architecture is typical of a thick firmware architecture, where
> the firmware handles all 802.11 MAC management tasks.  The host driver
> downloads standard 802.3 frames to the firmware to be transmitted over
> the link as 802.11 frames.

Ah. This isn't clear from the driver as it's too big to go through in
detail. In particular, handing 802.3 frames to the firmware means you
cannot use d80211 (nor ieee80211).

> I thought these 2 things were essentially _the_ definition of fullmac,
> please correct me if I'm wrong.

I think you're right.

> Perhaps I just don't understand how flexible d80211 has become; when we
> last were talking about it 8 months ago, it appears that it could not
> handle parts that did significant pieces of work in firmware, like the
> 8388 does.  Do we have the functionality in d80211 yet to handle pieces
> that are a full mix of hybrid full/soft mac?

No.

> [...]
> Not quite; the driver doesn't have to deal with the Open System
> handshake or the Shared Key handshake.  Instead of Airo's 1-step
> process, this is a simple 2-step process.  Look at wlan_join.c,
> wlan_associate().  That's what happens; nothing more.

If everything is as simple as you wrote, why is the driver so
incredibly big? It's almost impossible to review it in a reasonable
time.

> [...]
> I think you may have gotten the wrong impression about the part due to
> the cruft in the driver.  We'll clean that stuff out, like the
> ENTER/LEAVE and a host of other junk.  But what we'd like is comments on
> how to clean it up and what other people think should get re-arranged,
> and maybe how it could be integrated with d80211 more.

It probably couldn't. But you could use cfg80211, at least.

> 2) How could we take advantage the region stuff and 802.11d code in
> d80211?  I was also under the impression that the region code and
> regulatory domain stuff was nowhere near decided on.  I believe there
> are full sessions on this at the LWS II this weekend.

Yes. That's the reason why not inventing another solution is probably a
good idea.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
