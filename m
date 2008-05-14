From: Jamie Lokier <jamie@shareable.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Wed, 14 May 2008 22:38:25 +0100
Message-ID: <20080514213825.GC23758@shareable.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <20080514143105.GB14987@shareable.org> <482B37F6.3080400@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Sage Weil <sage@newdream.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:46909 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbYENVie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 17:38:34 -0400
Content-Disposition: inline
In-Reply-To: <482B37F6.3080400@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Jamie Lokier wrote:
> >Look up "one-phase commit" or even "zero-phase commit".  (The
> >terminology is cheating a bit.)  As I've understood it, all commit
> >protocols have a step where each node guarantees it can commit if
> >asked and node failure at that point does not invalidate the guarantee
> >if the node recovers (if it can't maintain the guarantee, the node
> >doesn't recover in a technical sense and a higher level protocol may
> >reintegrate the node).  One/zero-phase commit extends that to
> >guaranteeing a certain amounts and types of data can be written before
> >it knows what the data is, so write messages within that window are
> >sufficient for global commits.  Guarantees can be acquired
> >asynchronously in advance of need, and can have time and other limits.
> >These guarantees are no different in principle from the 1-bit
> >guarantee offered by the "can you commit" phase of other commit
> >protocols, so they aren't as weak as they seem.
> 
> For several common Paxos usages, you can obtain consensus guarantees 
> well in advance of actually needing that guarantee, making the entire 
> process quite a bit more async and parallel.
> 
> Sort of a "write ahead" for consensus.

That's a lovely concise summary.

It seems all the classical texts on two-phase commit have made it
over-complicated all along.  "write ahead consensus" is both faster
and simpler in many respects.

-- Jamie
