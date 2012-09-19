From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: only run neigh_forced_gc() from one cpu
Date: Wed, 19 Sep 2012 08:54:40 -0400
Message-ID: <20120919125440.GB12352@hmsreliant.think-freely.org>
References: <1348046827.26523.571.camel@edumazet-glaptop>
 <20120919105038.GA12352@hmsreliant.think-freely.org>
 <1348052825.26523.676.camel@edumazet-glaptop>
 <1348052957.26523.680.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tom Herbert <therbert@google.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60391 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213Ab2ISMyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 08:54:55 -0400
Content-Disposition: inline
In-Reply-To: <1348052957.26523.680.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 19, 2012 at 01:09:17PM +0200, Eric Dumazet wrote:
> On Wed, 2012-09-19 at 13:07 +0200, Eric Dumazet wrote:
> > On Wed, 2012-09-19 at 06:50 -0400, Neil Horman wrote:
> > 
> > > This is going to cause callers in neigh_alloc to immediately fail their
> > > allocation attempts.  Would it be a good idea to modify that call site so that
> > > instead of returning NULL, instead reread tbl->entries before comparing to
> > > gc_thresh3, on the hope that the cpu in the garbage collecting routine has freed
> > > some entries?
> > 
> > neigh_alloc() fails only if gc_thresh3 is hit, and if it is hit, we are
> > under attack by definition.
> > 
> > (the gc is run every 5 seconds is above gc_thresh2, and below
> > gc_thresh3)
> > 
> > No matter what you try, the attacker is going to be the winner.
> > 
> > The best thing here is to drop packets, not spending several milli
> > seconds to serve one packet, as queues are going to tail drop anyway.
> > 
> 
> I meant several hundred of milli seconds per packet.
> 
> In our tests we even trigger a softlockup, so thats more than 10 seconds
> waiting for the rwlock, for a single packet.
> 
Ok, thanks for the explination
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
