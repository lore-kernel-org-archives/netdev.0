From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 0/2] cfg80211: firmware and hardware version
Date: Wed, 30 Sep 2009 21:13:41 -0400
Message-ID: <20091001011340.GA3123@tuxdriver.com>
References: <20090924180048.14503.9579.stgit@tikku> <43e72e890909241320j592e347die8a14f8bdd962ffb@mail.gmail.com> <20090925044258.GA2722@tuxdriver.com> <da94abde0909250947k5084db85vccafe0d3e74e2ecf@mail.gmail.com> <43e72e890909250953r1714c79bsa679b96ca6f5797@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kalle.valo@iki.fi>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54859 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755308AbZJABP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 21:15:57 -0400
Content-Disposition: inline
In-Reply-To: <43e72e890909250953r1714c79bsa679b96ca6f5797@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2009 at 09:53:35AM -0700, Luis R. Rodriguez wrote:
> On Fri, Sep 25, 2009 at 9:47 AM, Kalle Valo <kalle.valo@iki.fi> wrote:

> > But we want to export two strings to user space (at least for now), is
> > it really worth the effort to add ethtool support for such a minor
> > feature? Also I have understood that ethtool is implemented only for
> > ethernet drivers, I don't feel comfortable that we use ethernet driver
> > interfaces with 802.11 device drivers. They are so much different that
> > there isn't that much common functionality. That's why I prefer
> > nl80211 over ethtool.
> >
> > What do people think?
> 
> So for Wake-on-Wireless I ran into the same, ethtool just did not
> offer the same wake up events needed for wireless. I could have
> technically used ethtool and expanded it to support wireless but it
> just seemed dirty.
> 
> I agree that using ethtool seems overkill compared to the patches you posted.

I think you either overestimate the amount of trouble for implementing
(minimal) ethtool support or you underestimate the amount of
functionality available through that interface.  That, or you just
don't like using something named "eth"tool for wireless -- but hey,
let's be honest about the frames we send/receive to/from the kernel...
:-)

The ethtool interface provides functionality for viewing and modifying
eeprom contents, dumping registers, trigger self-tests, basic driver
info, getting and setting message reporting levels, external card
identification (hey, _could_ be useful!), and some other bits like
checksum offload that might(?) be useful in the future.  I understand
regarding the WoW vs. WoL issue but probably the answer is just to
add a new method for WoW...?

I'll post a patch series based on what Kalle sent but using ethtool
instead of nl80211...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
