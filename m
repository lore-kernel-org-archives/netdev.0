From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC 08/14] net: wireless: mac80211: shrink
 ieee80211_tx_info
Date: Mon, 2 Mar 2015 20:03:16 +0100
Message-ID: <20150302190316.GB9762@breakpoint.cc>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
 <1425318028-26531-9-git-send-email-fw@strlen.de>
 <1425322425.1906.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54433 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753590AbbCBTDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:03:18 -0500
Content-Disposition: inline
In-Reply-To: <1425322425.1906.4.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> wrote:
> On Mon, 2015-03-02 at 18:40 +0100, Florian Westphal wrote:
> > to make it fit into (future) 44-byte sized skb->cb[].
> > 
> > This works, since flags is only used to store values
> > from mac80211_tx_control_flags enum, and these are just 2 bits.
> > We can thus move this to the padding hole inside the union.
> > 
> > Also add BUILD_BUG_ON magic to make sure that the new flags
> > field doesn't share storage w. other members of the union.
> 
> This is really ugly - what's the point of this?

Eventually reducing skb size to make it fit into 3 cachelines again even
on 64bit architectures.  For that 40 bytes need to go.

> Mind you - we are actually acutely out of space and would rather have
> *more*, not less.

:-(

I'm not familiar with mac80211, aside from that it seemed to me
that 40 byte cb would be doable, given enough work.

Where are to main problems, exactly?

I known that pushing something into ->cb is a lot easier than e.g. keeping
extra state on stack, but, IMO cb should really only be used when you
need to associate data strictly with an skb so that this data is still
availabe even when skb gets queued somewehere.

Is there a document somewhere that lists all of the per-skb data that
mac80211 needs to store (or wants to store)?

Thanks,
Florian
