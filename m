From: Daniel Walker <dwalker@mvista.com>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sat, 20 Sep 2008 09:02:09 -0700
Message-ID: <1221926529.1343.140.camel@localhost.localdomain>
References: <20080919.234824.223177211.davem@davemloft.net>
	 <1221924561.1343.121.camel@localhost.localdomain>
	 <20080920084512.58f7fb08@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:15169 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbYITQCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 12:02:15 -0400
In-Reply-To: <20080920084512.58f7fb08@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-09-20 at 08:45 -0700, Arjan van de Ven wrote:
> On Sat, 20 Sep 2008 08:29:21 -0700
> > 
> > > Jen's, as stated, has block layer uses for this.  I intend to use
> > > this for receive side flow seperation on non-multiqueue network
> > > cards.  And Steffen Klassert has a set of IPSEC parallelization
> > > changes that can very likely make use of this.
> > 
> > What's the benefit that you (or Jens) sees from migrating softirqs
> > from specific cpu's to others?
> 
> it means you do all the processing on the CPU that submitted the IO in
> the first place, and likely still has the various metadata pieces in
> its CPU cache (or at least you know you won't need to bounce them over)


In the case of networking and block I would think a lot of the softirq
activity is asserted from userspace.. Maybe the scheduler shouldn't be
migrating these tasks, or could take this softirq activity into
account ..

Daniel

