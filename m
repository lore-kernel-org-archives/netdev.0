From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Sat, 15 Sep 2007 09:03:53 -0500
Message-ID: <46EBE649.3040303@opengridcomputing.com>
References: <adahclymos8.fsf@cisco.com>	<46E97BB0.9030106@opengridcomputing.com> <adaps0ml18e.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([71.42.183.126]:41049 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750983AbXIOOD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2007 10:03:56 -0400
In-Reply-To: <adaps0ml18e.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Roland Dreier wrote:
>  > I was about to post v2 of my patch to avoid port space collisions with
>  > the native stack.  Can we get that 2.6.24?  It is high priority
>  > IMO. I've tried to solicit review on it, but I think folks are
>  > reluctant... ;-)
> 
> I would like to get this in, but I'm still at least a little
> reluctant, since we would be committing to a user interface that seems
> a little awkward at best, so I'd like to try and find something
> better.  Just to summarize my understanding:
> 
>  - your patch requires the administration to configure an ethX:iwY
>    alias address to use iwarp.  (By the way is there anything other
>    than "don't do that" that avoids assigning the same address to the
>    iwarp alias and a non-iwarp interface?)
> 

Nope.  Its totally up to the admin to create the ethX:iwY interface 
-and- to segment his services so host TCP runs on the ethX subnet(s) and 
the iwarp rdma ones run on ethX:iwY subnet(s).  Without changing the 
core network serices, I don't see any way around this.

>  - it would be nicer to create the alias automatically, but an alias
>    without an address doesn't make sense.  Creating a whole separate
>    net device causes problems because the iwarp stuff still needs to
>    use the main net device to do ARP etc.
>

I do log a warning if an iwarp application binds to address 0.0.0.0 and 
there are no ethX:iwY address available.

>  - so I'm out of better ideas but I still want to push back a little
>    before we commit to something ugly.
> 

Me 2. :-(

> I've been meaning to track down the bnx2 iscsi offload patch to look
> and see if this issue is addressed, since the same problem seems to
> exist: it seems an iscsi connection and a main stack tcp connection
> might share the same 4-tuple unless something is done to avoid that
> happening.
> 
> Also, I think it behooves us to get some agreement on this approach
> with NetEffect and Kanoj (NetXen?) at least, since their iwarp drivers
> seem to be imminent.
> 
>  - R.
