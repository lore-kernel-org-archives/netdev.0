From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netem: Segment GSO packets on enqueue.
Date: Wed, 27 Apr 2016 07:27:48 -0400
Message-ID: <20160427112748.GA23299@hmsreliant.think-freely.org>
References: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
 <1461696598.5535.35.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160426190026.GB12788@hmsreliant.think-freely.org>
 <1461701955.5535.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47220 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbcD0L2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 07:28:02 -0400
Content-Disposition: inline
In-Reply-To: <1461701955.5535.38.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 01:19:15PM -0700, Eric Dumazet wrote:
> On Tue, 2016-04-26 at 15:00 -0400, Neil Horman wrote:
> > I can understand that, but that raises two questions in my mind:
> > 
> > 1)  Doesn't that make all the statistical manipulation for netem wrong?  That is
> > to say, if netem drops 5% of packets, and it happens to drop a GSO packet, its
> > actually dropping several, instead of the single one required.
> 
> 
> Please take a look at tbf_segment(), where you can find a proper way to
> handle this.
> 
> Note that for the case q->corrupt is 0, we definitely do not want to
> segment TSO packets.
> 
> > 2) How are you getting netem to work with GSO at all?  The warning is triggered
> > for me on every GSO packet, which I think would impact throughput :)
> 
> I mostly use netem to add delays and drops.
> I never had this bug, since q->corrupt = 0
> 

I see what you're saying now, I should only be segmenting the packet if the
qdisc needs to compute the checksum on each packet.  Other packets that aren't
selected to be mangled can pass through un-segmented (assuming they meet any
other queue constraints).

Ok, thanks.  Self-nak.  I'll respin/test and post a new version

Best
Neil

> 
> 
> 
