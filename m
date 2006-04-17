From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH][RFC] softmac: suggest TX rate
Date: Mon, 17 Apr 2006 02:33:55 +0200 (CEST)
Message-ID: <Pine.LNX.4.58.0604170230400.32281@p15091797.pureserver.info>
References: <4442E13E.80507@gentoo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Johannes Berg <johannes@sipsolutions.net>,
	softmac-dev@sipsolutions.net, netdev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:63931 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1750869AbWDQAe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 20:34:58 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4442E13E.80507@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Apr 2006, Daniel Drake wrote:

> While developing the ZD1211 driver we realised how much we'd like to be
> advised from the upper layers which rate to transmit a packet at.
> 
> An example: We have a frame to transmit. What rate should we transmit it at?
> While taking any user-specified rate into account too, we want to transmit it
> at a rate supported by the access point, but that information is not available
> to us (softmac handled all scanning and association, so we don't know anything
> about the AP capabilities).
> 
> Here is a patch I cooked up, which implements some basic logic for suggesting
> TX rates based on the packet type, whether it is multicast/unicast, whether we
> are associated, and the current user-specified default_rate.
> 
> I'm still uncertain where this functionality should fit into the stack.
> 
> Rather than having to explicitly call ieee80211softmac_suggest_tx_rate() from
> the driver's hard_start_xmit function, it would be nicer if the suggested rate
> was passed as a parameter. But not all drivers would need it, so maybe the
> extra calculations should be controlled by a new flag.
> 
> Passing an extra parameter to hard_start_xmit would involve modifying
> ieee80211, and ieee80211 doesn't seem to have any concept of whether it is
> associated or not (plus softmac only does that loosely). So that might lead us
> on to do something silly like wrapping hard_start_xmit inside softmac, etc
> etc...
> 
> Note that even in it's current form, this patch eliminates an annoying (and
> inaccurate) chunk of code from our driver.
> 
> Ideas/comments?
> 

-- 
Ulrich Kunitz - kune@deine-taler.de
