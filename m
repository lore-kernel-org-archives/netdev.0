From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bond + tc regression ?
Date: Tue, 5 May 2009 16:52:53 -0700
Message-ID: <20090505165253.21f9e086@nehalam>
References: <1241538358.27647.9.camel@hazard2.francoudi.com>
	<4A0069F3.5030607@cosmosbay.com>
	<20090505174135.GA29716@francoudi.com>
	<4A008A72.6030607@cosmosbay.com>
	<20090505235008.GA17690@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40122 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209AbZEEXw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 19:52:59 -0400
In-Reply-To: <20090505235008.GA17690@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 May 2009 02:50:08 +0300
Vladimir Ivashchenko <hazard@francoudi.com> wrote:

> On Tue, May 05, 2009 at 08:50:26PM +0200, Eric Dumazet wrote:
> 
> > > I have tried with IRQs bound to one CPU per NIC. Same result.
> > 
> > Did you check "grep eth /proc/interrupts" that your affinities setup 
> > were indeed taken into account ?
> > 
> > You should use same CPU for eth0 and eth2 (bond0),
> > 
> > and another CPU for eth1 and eth3 (bond1)
> 
> Ok, the best result is when assign all IRQs to the same CPU. Zero drops.
> 
> When I bind slaves of bond interfaces to the same CPU, I start to get 
> some drops, but much less than before. I didn't play with combinations.
> 
> My problem is, after applying your accounting patch below, one of my 
> HTB servers reports only 30-40% CPU idle on one of the cores. That won't 
> take me for very long, load balancing across cores is needed.
> 
> Is there any way at least to balance individual NICs on per core basis?
> 

The user level irqbalance program is a good place to start:
  http://www.irqbalance.org/
But it doesn't yet no how to handle multi-queue devices, and it seems
to not handle NUMA (like SMP Nehalam) perfectly.
