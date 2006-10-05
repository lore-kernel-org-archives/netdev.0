From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Thu, 05 Oct 2006 09:47:32 +0200
Message-ID: <1160034452.2728.2.camel@ux156>
References: <1159435399.2648.17.camel@ux156>
	 <1159805711.2834.67.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:4501 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750713AbWJEHqp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 03:46:45 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1159805711.2834.67.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Umm, looks like I skipped this paragraph in my earlier reply to you. Sorry
about that.

> I'd also argue that one specific BSSID is part of an initial
> configuration.  We should support that in config command.  It's an
> implicit SET_FIXED_BSSID, yes.  But one of the major points of
> nl80211/cfg80211 was that you could bundle up a set of configuration
> settings into a single atomic "packet", which you couldn't do with WE.
> 
> So if a specific BSSID isn't sent in the initial config command, when do
> you set a specific BSSID?  Before?  After?  The behavior starts getting
> complicated, and we're back to a situation where every driver implements
> the semantics in a slightly different manner.

Ah, good point. But then, why would you want to set a specific (initial)
BSSID at all? Either you set userspace roaming (which you'd do before
setting the SSID) then the kernel can't do anything without you setting a
BSSID, or you don't set userspace roaming, then all the kernel needs is the
SSID.

I'm thinking you probably want something like 'list of BSSIDs to use for
userspace roaming' and possibly a blacklist too, although I'm inclined to
let userspace manage the blacklist by way of having a whitelist *only* and
having userspace simply add everything to the whitelist that it discovers
through scanning and isn't on the blacklist...

Hence, would you be satisfied with a BSSID-whitelist for kernel-controlled
roaming (userspace roaming doesn't need the kernel to know about the
whitelist)? Heck, you could even use a single-element whitelist for when you
want to force the kernel to associate to that AP... Maybe we should thus
drop the userspace roaming support? I think it's a simpler API though...
Then again, why do we need a BSSID-whitelist? Just have userspace control
roaming then...

Also, the use case you want could probably be achieved by turning on
userspace roaming, setting the BSSID for it, configuring the SSID and then
turning off userspace roaming again.

Or let me put it another way: I'm not sure what the use case actually is :)

johannes
