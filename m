From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Thu, 16 Apr 2015 06:24:00 +0100
Message-ID: <20150416052357.GA3285@acer.localdomain>
References: <20150413.135348.461869719021663434.davem@davemloft.net>
 <20150416045622.GA12454@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64402 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbbDPFYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 01:24:15 -0400
Content-Disposition: inline
In-Reply-To: <20150416045622.GA12454@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.04, Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
> > 
> > Because then there is no ambiguity at all, you preserve on output
> > exactly what you had on input.  The same geometry, the same
> > everything.  No special checks, no max frag len, none of this crap.
> > Those are all hacks trying to work around the _fundamental_ issue
> > which is that we potentially change the thing when we refrag.
> 
> Agreed.  Doing anything other than preserving the original geometry
> is simply wrong.
> 
> However, this doesn't mean that netfilter has to process each
> fragment.  What we could do is to preserve the original fragments
> in frag_list and then process the overall skb as a unit in netfilter.
> 
> On output we simply fragment according to the original frag_list.
> 
> The only thing to watch out for is to eliminate anything in the
> middle that tries to linearise the skb.

Netfilter may change the contents of the packet, even change its size.
It is *really* hard to do this while keeping the original fragments
intact.
