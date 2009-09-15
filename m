From: Simon Horman <horms@verge.net.au>
Subject: Re: igb bandwidth allocation configuration
Date: Wed, 16 Sep 2009 08:29:26 +1000
Message-ID: <20090915222926.GA24467@verge.net.au>
References: <20090910081844.GA5421@verge.net.au>
 <15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>
 <20090915113659.GJ24194@verge.net.au>
 <4AAF963D.4060708@voltaire.com>
 <4AAFD690.5040900@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@voltaire.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39124 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbZIOW3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 18:29:25 -0400
Content-Disposition: inline
In-Reply-To: <4AAFD690.5040900@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2009 at 11:01:52AM -0700, Alexander Duyck wrote:
> Or Gerlitz wrote:
> >If the rate limiter is exposed as a feature of the VF, it doesn't
> >matter who really enforces it, the "VF portion" of the HW or the
> >PF itself. I agree that if you have to program the PF for the rate
> >of a specific VF, then its more complex. Basically, I would expect
> >that a VF can be configured with <mac, vlad-id, priority, rate>
> >such that it can be done where the VF NIC is spawned, host kernel
> >or guest kernel.
> 
> Adding the rate limiter as a feature of the VF doesn't make much
> sense since the VF could be direct assigned to another OS for all we
> know so we won't have control over it from there.
> 
> The interface for all of this would make sense as part of a virtual
> ethernet switch control which is the way I am currently leaning on
> all this.  As such it is probably another thing we can bring up at
> the BOF session at the Linux Plumbers Conference.

Unfortunately I won't be able to make it to the BOF or Plumbers.
I look forward to hearing what is discussed.

> >I'm was asking/wondering if the Intel NICs have a rate limiter
> >(i.e one can program the VF such that its rate doesn't exceed XX
> >MB/s) or a "rate guarantee"  (i.e one can program the VF such that
> >its guaranteed it will get YY MB/s in case it wants to xmit at
> >least this bandwidth)
> 
> Based on the way I am reading the documentation I would say the all
> these registers do is guarantee a minimum percentage of the
> bandwidth. With these registers set you can repartition the traffic
> so that a percentage can be guaranteed to the PF/VFs if needed.  It
> works very similar to how DCB allows you to guarantee a certain
> amount of bandwidth for each of the traffic classes.  However any
> time the full tx bandwidth is not being used it will be reallocated
> to the other queues and then end up back in the default behavior.
> 
> The default behavior is to DMA descriptors from the rings in a round
> robin fashion.  Since this effectively guarantees that there will be
> packets being pulled off the rings I didn't really feel the
> necessity to add the additional overhead of doing this on a per
> PF/VF bandwidth basis.

My reading of the documentation is also that its a minimum percentage of
bandwidth. But after playing with the registers a bit it seems
that it is actually a ceiling expressed. And the percentage is of 1Gigabit,
regardless of the actual link speed.

