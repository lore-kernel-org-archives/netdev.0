From: Chris Snook <csnook@redhat.com>
Subject: Re: Bonding gigabit and fast?
Date: Tue, 16 Dec 2008 14:54:29 -0500
Message-ID: <49480775.4060408@redhat.com>
References: <200812161939.30033.tvrtko@ursulin.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57811 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752860AbYLPTyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 14:54:39 -0500
In-Reply-To: <200812161939.30033.tvrtko@ursulin.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tvrtko A. Ursulin wrote:
> Hi to all,
> 
> Does it make any sense from bandwith point of view to bond gigabit and fast 
> ethernet?

Not unless there's something very wrong with your gigabit card.  People with 
this sort of hardware generally use the fast ethernet for management or cluster 
heartbeat, or maybe as a non-primary slave in an active-backup bond.

> I wanted to use adaptive-alb mode to load balance both transmit and receive 
> direction of traffic but it seems 8139too does not support it so I use 
> balance-rr.
> 
> When serving data from the machine I get 13.7 MB/s aggregated while with a 
> single slave (so bond still active) I get 5.6 MB/s for gigabit and 9.1 MB/s 
> for fast. Yes, that's not a typo - fast ethernet is faster than gigabit.

That would qualify as something very wrong with your gigabit card.  What do you 
get when bonding is completely disabled?

> That is actually another problem I was trying to get to the bottom of for some 
> time. Gigabit adapter is skge in a PCI slot and outgoing bandwith oscillates 
> a lot during transfer, much more than on 8139too which is both stable and 
> faster.

The gigabit card might be sharing a PCI bus with your disk controller, so 
swapping which slots the cards are in might make gigabit work faster, but it 
sounds more like the driver is doing something stupid with interrupt servicing.

> Unfortunately this machine takes low-profile cards and so far I was unable to 
> find something other than skge to test with.
> 
> Oh and yes, kernel is 2.6.27(-9-generic, so Ubuntu derivative of 2.6.27).

