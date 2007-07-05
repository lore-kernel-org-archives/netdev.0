From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Who's allowed to set a skb destructor?
Date: Thu, 5 Jul 2007 15:51:48 +0200
Message-ID: <20070705135148.GC4759@ff.dom.local>
References: <p733b032mec.fsf@bingen.suse.de> <20070705122849.GA4759@ff.dom.local> <20070705130640.GA24731@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brice Goglin <Brice.Goglin@ens-lyon.org>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Divy Le Ray <divy@chelsio.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:44630 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757100AbXGENnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 09:43:20 -0400
Content-Disposition: inline
In-Reply-To: <20070705130640.GA24731@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2007 at 03:06:40PM +0200, Andi Kleen wrote:
> On Thu, Jul 05, 2007 at 02:28:50PM +0200, Jarek Poplawski wrote:
> > I wonder if it's very unsound to think about a one way list
> > of destructors. Of course, not owners could only clean their
> > private allocations. Woudn't this save some skb clonning,
> > copying or adding new fields for private infos?
> 
> skb cloning isn't very expensive when you need it. And they
> got a little private area you can use for your own stuff 
> while you have it queued (skb->cb) 

Not expensive in speed, but allocating size_of skb when
you e.g. need 2 or 3 integers looks like a little expensive.

> 
> As a historical note one of the big changes during the Linux 2.0
> and 2.1 TCP rewrite was that TCP was changed to always clone for the
> retransmit queue. This cleaned up the code greatly and fixed
> many problems. Cloning was also especially optimized for this. When TCP 
> which is about one of the most performance critical protocols around can 
> afford it likely other code can too.

I've read opinions that current skb structure is far from
optimal. So, it seems clonnig wasn't enough in many situations,
and fiels were added. Of course, it's only a part of the story:
some other clients couldn't think about the structure changed
for them, so probably made it other, more expensive way?
 
Jarek P.
