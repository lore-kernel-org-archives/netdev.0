From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] about "net: orphan frags on receive" insanity
Date: Wed, 26 Jun 2013 21:56:14 +0300
Message-ID: <20130626185614.GA10713@redhat.com>
References: <1372235039.3301.126.camel@edumazet-glaptop>
 <20130626095642.GA20982@redhat.com>
 <1372241543.3301.157.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41960 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658Ab3FZSz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 14:55:27 -0400
Content-Disposition: inline
In-Reply-To: <1372241543.3301.157.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 03:12:23AM -0700, Eric Dumazet wrote:
> On Wed, 2013-06-26 at 12:56 +0300, Michael S. Tsirkin wrote:
> 
> > Please don't just revert it.
> 
> I said "revert and fix the callers"
> 
> > 
> > Packets can cross e.g. the bridge and end up on the external
> > interface, in which case that NIC guarantees that
> > they will get transmitted eventually, so it's safe
> > to transmit from guest memory, or they can end up
> > in the host stack where they can stay indefinitely,
> > in this case we need to orphan frags so guest networking
> > can keep going.
> > 
> > What do you suggest exactly?
> > 
> > Also, I'll have to look at the generated binary - when I
> > coded this up, compiler seemed to only put a
> > conditional branch on the fast path, this shouldn't
> > be all that expensive.
> 
> Then look again. Its 400 bytes right now.
> 
> I suggested to call this only from the impacted callers.

Well we don't want to duplicate the whole RX path
to special-case that, right?

> VM are fine, but if we slow down bare metal to close the gap, or make
> appealing kernel bypass, that's not very fair.
> 
> Why normal frames received from real NIC should pay this price, I don't
> know.
> 
> The conditional branch might sound not expensive, but the cache line
> miss on skb_shinfo(skb)->tx_flags is expensive.
> 

Okay, for the RX path, I think we can set a
separate flag in the skb itself, and branch
based on that.

Would this address the comment?

-- 
MST
