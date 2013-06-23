From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: possible bug in IPv6 MLD retransmissions
Date: Sun, 23 Jun 2013 16:18:02 +0200
Message-ID: <20130623141802.GA13836@order.stressinduktion.org>
References: <20130517032449.GA3595@obelix.rh> <20130518173105.GD29528@order.stressinduktion.org> <20130521150616.GA8513@obelix.rh> <20130522004027.GD32093@order.stressinduktion.org> <OF1A7F184A.4282AFE8-ON85257B73.003E82A8-85257B73.003F3B88@us.ibm.com> <20130523202156.GJ17411@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60826 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab3FWOSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 10:18:05 -0400
Content-Disposition: inline
In-Reply-To: <20130523202156.GJ17411@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 23, 2013 at 10:21:56PM +0200, Hannes Frederic Sowa wrote:
> On Wed, May 22, 2013 at 07:30:39AM -0400, David Stevens wrote:
> > Second, I think doing this on all LL addresses unconditionally isn't a 
> > good
> > idea. If some configuration is using thousands of LL addrs for reasons of 
> > their
> > own, they would suddenly be blasted with unexpected MLD reports where
> > they have none now. I don't see why tracking it would be such a problem --
> > if nothing else, you could simply add a counter for the number of valid LL 
> > addrs
> > incremented on DAD completion, and send these whenever it transitions from 
> > 0 to 1.
> 
> While testing some code, I noticed that we seem to have a similar
> problem with the generation of router soliciations. We send out
> MAX_RTR_SOLICITATIONS for each link-local address dad completion.
> 
> So the tracking could have some more users and I will move it to
> addrconf.c. I'll hope I cope with all the tiny races I found in my last
> version. :)

Sorry, I could not finish this patch before I got distracted with other
things. I had a look at it again yesterday and came up with the following
plan:

a) split up router advertisment and dad timer
b) remove src-argument from ndisc_send_rs and calculate it from the ll
   addresses of the interface when sending the RS
c) introduce ll_dad_completion counter
d) rebase the above patch onto this utilising the ll_dad_completion counter

Does this plan sound solid?

I plan to send out a patch for a) today.

Greetings,

  Hannes
