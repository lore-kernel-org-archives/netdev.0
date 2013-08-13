From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec smp scalability and cpu use fairness (softirqs)
Date: Tue, 13 Aug 2013 12:45:48 +0200
Message-ID: <20130813104548.GB26773@secunet.com>
References: <20130812160142.71737a95@vostro>
 <CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
 <20130813092312.2493354e@vostro>
 <20130813074614.GM25511@secunet.com>
 <20130813105757.39fb0ab8@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Collins <bsderandrew@gmail.com>, netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48350 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757383Ab3HMKpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 06:45:51 -0400
Content-Disposition: inline
In-Reply-To: <20130813105757.39fb0ab8@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 10:57:57AM +0300, Timo Teras wrote:
> On Tue, 13 Aug 2013 09:46:14 +0200
> Steffen Klassert <steffen.klassert@secunet.com> wrote:
> 
> > Also, if you want parallelism, you could use the pcrypt algorithm.
> > It sends the crypto requests asynchronously round robin to a
> > configurable set of cpus. Finaly it takes care to bring the
> > served crypto requests back into the order they were submitted
> > to avoid packet reordering.
> 
> Right. Looks like this helps a lot.
> 
> Perhaps it would be worth to experiment also with RPS type hash based
> cpu selection?
> 

Actually, this was the reason why I started to write the below mentioned
patches. The idea behind that was to use a combination of flow based
and inner flow parallelization.

On bigger NUMA machines it does not make much sense to use all
cores for parallelization. The performance depends too much on the
actual topology. Moving crypto requests to another NUMA node can
even reduce performance. So I wanted to use RPS type hash based
cpu selection to choose the node for a given flow and then use
pcrypt to parallelize this flow on the chosen node.

> > Currently we have only one systemwide workqueue for encryption
> > and one decryption. So all IPsec packets are send to the same
> > workqueue, regardless which state they use.
> > 
> > I have patches that make it possible to configure a separate
> > workqueue for each state or to group some states to a specific
> > workqueue. These patches are still unpublished because they
> > have not much testing yet, but I could send them after some
> > polishing for review or testing if you are interested.
> 
> Yes, I'd be interested.
> 

Ok, I'll send them. May take some days to rebase and polish.
