From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 13 Jan 2009 16:07:21 -0800 (PST)
Message-ID: <20090113.160721.68474279.davem@davemloft.net>
References: <20090111133533.GB25337@ioremap.net>
	<496A17A5.7010200@cosmosbay.com>
	<20090111160548.GA362@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, w@1wt.eu, ben@zeus.com, jarkao2@gmail.com,
	mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52130
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756718AbZANAHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 19:07:21 -0500
In-Reply-To: <20090111160548.GA362@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Sun, 11 Jan 2009 19:05:48 +0300

> On Sun, Jan 11, 2009 at 05:00:37PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > While we drop lock in skb_splice_bits() to prevent the deadlock, we
> > also process backlog at this stage. No need to process backlog
> > again in the higher level function.
> 
> Yes, but having it earlier allows to receive new skb while processing
> already received.
> 
> > > I think that even with non-blocking splice that release_sock/lock_sock
> > > is needed, since we are able to do a parallel job: to receive new data
> > > (scheduled by early release_sock backlog processing) in bh and to
> > > process already received data via splice codepath.
> > > Maybe in non-blocking splice mode this is not an issue though, but for
> > > the blocking mode this allows to grab more skbs at once in skb_splice_bits.
> > 
> > skb_splice_bits() operates on one skb, you lost me :)
> 
> Exactly, and to have it we earlier release a socket so that it could be
> acked and while we copy it or doing anything else, the next one would
> received.

I think the socket release in skb_splice_bits() (although necessary)
just muddies the waters, and whether the extra one done in
tcp_splice_read() helps at all is open to debate.

That skb_clone() done by skb_splice_bits() pisses me off too,
we really ought to fix that.  And we also have that data corruption
bug to cure too.
