From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Fri, 17 Apr 2015 01:44:09 +0200
Message-ID: <20150416234409.GB2939@acer.localdomain>
References: <20150416052357.GA3285@acer.localdomain>
 <20150416052904.GA12648@gondor.apana.org.au>
 <1429186302.1075929.254563877.238D8F77@webmail.messagingengine.com>
 <20150416.114323.2122666447487730641.davem@davemloft.net>
 <1429200805.1141475.254665081.0E1724C4@webmail.messagingengine.com>
 <20150416204702.GA20616@gondor.apana.org.au>
 <20150416205646.GB4020@acer.localdomain>
 <1429226161.2585513.254850009.26B43D4D@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40163 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbbDPXoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:44:13 -0400
Content-Disposition: inline
In-Reply-To: <1429226161.2585513.254850009.26B43D4D@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.04, Hannes Frederic Sowa wrote:
> 
> 
> On Thu, Apr 16, 2015, at 22:56, Patrick McHardy wrote:
> > On 17.04, Herbert Xu wrote:
> > > On Thu, Apr 16, 2015 at 06:13:25PM +0200, Hannes Frederic Sowa wrote:
> > > >
> > > > So currently we have one fast path, that is: we are not fragmented, we
> > > > get out non-fragmented, none of this code is ever touched and no
> > > > problem.
> > > > 
> > > > We don't want to mak this more complex, but
> > > 
> > > You should read Dave's other email where he gives you an obvious
> > > solution.  If you have to modify the skb then you don't have to
> > > worry about the original fragments.
> > > 
> > > But if you only read the skb then don't linearise it completely
> > > and keep the original fragments.
> > 
> > Yes, I was just responding to that. We need an additional member
> > in the skb, but then this part is quite simple.
> 
> I guess you refer to the solution of using the fragmented list of
> packets to do checks. I don't think it will be that simple to peek into
> all the different skbs if the fragments are split in the header.
> Splitting fragments in the header is the 1x1 of firewall by-passing
> attacks, so we should certainly handle it correctly.

Also correct, that argument hasn't come up so far. Its actually not
too hard to handle, you need to keep track of which parts have been
inspected to make a classification decision and make sure those
parts are not overwritten. The TCP match does this statically, but
we certainly could do this dynamically. The question again is how
to keep geometry if things are actually overwritten, especially
partially. Apparently all this troubly is being seen as worthwhile.

> Logic off peeking into fragments and splitting fragments must be
> logically consent all the time, with all netfilter helpers in the tree.
> 
> I don't think the additional checks in fast-path are in any way
> justified.

I fully agree.

> 
> Bye,
> Hannes
> 
