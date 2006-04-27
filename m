From: Kelly Daly <kelly@au1.ibm.com>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 27 Apr 2006 13:31:37 +1000
Message-ID: <200604271331.37073.kelly@au.ibm.com>
References: <200604261147.34221.kelly@au.ibm.com> <20060426.003335.26972263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:30192 "EHLO
	ausmtp04.au.ibm.com") by vger.kernel.org with ESMTP id S964910AbWD0Dby
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 23:31:54 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.6/8.13.5) with ESMTP id k3R3fp2Z269540
	for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 13:41:52 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3R3Yx3p208010
	for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 13:35:04 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11/8.13.3) with ESMTP id k3R3Vdw4012081
	for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 13:31:39 +1000
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060426.003335.26972263.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Thanks for your response.  =)

On Wednesday 26 April 2006 17:59, you wrote:
> Ok I have comments already just glancing at the initial patch.
>
> With the 32-bit descriptors in the channel, you indeed end up
> with a fixed sized pool with a lot of hard-to-finesse sizing
> and lookup problems to solve.

It should be quite trivial to resize this pool using RCU.

>
> So what I wanted to do was finesse the entire issue by simply
> side-stepping it initially.  Use a normal buffer with a tail
> descriptor, when you enqueue you give a tail descriptor pointer.


The tail pointers are an excellent idea - and they certainly fix a lot of 
compatibility issues that we side-stepped (we were going for the "make it 
work" approach rather than the "make it right" - figured we could get to that 
bit later  =P  ).

> I really dislike the pools of buffers, partly because they are fixed
> size (or dynamically sized and even more expensive to implement), but
> moreso because there is all of this absolutely stupid state management
> you eat just to get at the real data.  That's pointless, we're trying
> to make this as light as possible.  Just use real pointers and
> describe the packet with a tail descriptor.

We approached this from the understanding that an intelligent NIC will be able 
to transition directly to userspace, which is a major win.  0 copies to 
userspace would be sweet.  I think we can still achieve this using your 
scheme without *too* much pain.

> Next, you can't even begin to work on the protocol channels before you
> do one very important piece of work.  Integration of all of the ipv4
> and ipv6 protocol hash tables into a central code, it's a total
> prerequisite.  Then you modify things to use a generic
> inet_{,listen_}lookup() or inet6_{,listen_}lookup() that takes a
> protocol number as well as saddr/daddr/sport/dport and searches
> from a central table.

Understood.  And agreed.  Once again was side-stepped just to try to get a 
"working model".  Will look into this immediately.

> So I think I'll continue working on my implementation, it's more
> transitional and that's how we have to do this kind of work.


Thanks again for your comments  =) (and thanks to everyone else who took the 
time to respond to this)

Kelly
