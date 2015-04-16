From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Thu, 16 Apr 2015 22:55:48 +0200
Message-ID: <20150416205547.GA4020@acer.localdomain>
References: <20150413.135348.461869719021663434.davem@davemloft.net>
 <20150416045622.GA12454@gondor.apana.org.au>
 <20150416052357.GA3285@acer.localdomain>
 <20150416.113218.1551818529213866015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39028 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706AbbDPUzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 16:55:55 -0400
Content-Disposition: inline
In-Reply-To: <20150416.113218.1551818529213866015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.04, David Miller wrote:
> > Netfilter may change the contents of the packet, even change its size.
> > It is *really* hard to do this while keeping the original fragments
> > intact.
> 
> I keep hearing a lot of "it's hard" as the only reason we shouldn't do
> this properly, and that frankly sucks.  People aren't looking for a
> solution and to be honest it's quite tiring.
> 
> The common case is that the rules processed are simple, the size of
> the overall packet does _not_ change, and therefore the best thing
> to do is pass the entire thing as a unit with the frags in tact.
> 
> That's the fundamental fact.  It's also the fastest way to process
> these packets and avoids all of these stupid max frag garbage.
> 
> Only at the point where netfilter makes changes to the size of the
> packet does it take "ownership" and get to take on the responsibility
> of making sure the new resulting fragments are sane.
> 
> But only at that point.

Agreed, that part shouldn't be hard. We need to pass the defragmented
skb through the ruleset, meaning we need to pass it through the stack.
That's needed since the rules depend on this.

If we don't make changes, we can spit out the original fragments, but
for this we need to keep a reference to them from the skb. We still
need the max_frag_size thing, once a modification is made we drop the
frag list reference and just regulary refragment the modified skb
according to the limits.
