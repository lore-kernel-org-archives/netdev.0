From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Sat, 2 Feb 2008 05:10:05 +0100
Message-ID: <20080202041005.GB12644@one.firstfloor.org>
References: <20080131124632.GA25299@basil.nowhere.org> <47A212CB.1060403@hp.com> <20080131190326.GF4671@one.firstfloor.org> <47A39606.4090401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51340 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895AbYBBDfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 22:35:34 -0500
Content-Disposition: inline
In-Reply-To: <47A39606.4090401@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2008 at 01:58:30PM -0800, Rick Jones wrote:
> >>Does this also imply that JumboFrames interacts badly with these qdiscs? 
> >>Or IPoIB with its 65000ish byte MTU?
> >
> >
> >Correct. Of course it is always relative to the link speed. So if your
> >link is 10x faster and your packets 10x bigger you can get similarly
> >smooth shaping.
> 
> If the later-in-thread mentioned person shaping for their DSL line 
> happens to have enabled JumboFrames on their GbE network, will/should 
> the qdisc negate that? 

I don't think so, mostly because jumbo frames are not enabled by
default.  I'm only concerned about usable defaults there -- if you
set non default options you should certainly know what you're doing.

There are other reasons to not use jumbo frames anyways; e.g. a lot 
of cards still do not support SG for them but only process 
them as a single continuous buffer in memory so you often run 
into memory fragmentation problems.

> Or is the qdisc currently assuming that the 
> remote end of the DSL will have asked for a smaller MSS?

First there are lots of different qdiscs that all do different things.
Take a look at net/sched/*. Then they usually don't strictly require particular
MTUs (or know anything about MSS), but tend to work better with smaller
MTUs because that allows more choices in packet scheduling.  Generally
the larger your packets the less they can be scheduled.

-Andi

