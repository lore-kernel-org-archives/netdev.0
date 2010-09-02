From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Wed, 1 Sep 2010 18:48:02 -0700
Message-ID: <20100901184802.5a79cf9f@nehalam>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
	<1283356463.2556.351.camel@edumazet-laptop>
	<AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com>
	<20100901.183251.106803238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49279 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752420Ab0IBBsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 21:48:05 -0400
In-Reply-To: <20100901.183251.106803238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Sep 2010 18:32:51 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Tom Herbert <therbert@google.com>
> Date: Wed, 1 Sep 2010 09:24:18 -0700
> 
> > On Wed, Sep 1, 2010 at 8:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> 3) Eventually have a user selectable selection (socket option, or system
> >> wide, but one sysctl, not many bitmasks ;) ).
> >>
> > Right, but it would also be nice if a single sysctl could optimally
> > set up multiqueue, RSS, RPS, and all my interrupt affinities for me
> > ;-)
> 
> It's becomming increasingly obvious to me that we need (somewhere,
> not necessarily the kernel) a complete datastructure representing
> the NUMA, cache, cpu, device hierarchy.
> 
> And that can be used to tweak all of this stuff.
> 
> The policy should probably be in userspace, we just need to provide
> the knobs in the kernel to tweak it however userspace wants.
> 
> Userspace should be able to, for example, move a TX queue into a
> NUMA domain and have this invoke several side effects:
> 
> 1) IRQs for that TX queue get rerouted to a cpu in the NUMA
>    domain.
> 
> 2) TX queue datastructures in the driver get reallocated using
>    memory in that NUMA domain.
> 
> 3) TX hashing is configured to use the set of cpus in the NUMA
>    domain.
> 
> It's alot of tedious work and involves some delicate tasks figuring
> out where each of these things go, but really then we'd solve all
> of this crap one and for all.

Plus it needs to work with scheduler (not fight it).  All this doesn't
work very well if process keeps bouncing away from its resources.

-- 
