From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: RDMA will be reverted
Date: Thu, 06 Jul 2006 19:32:31 -0500
Message-ID: <1152232351.20248.139.camel@trinity.ogc.int>
References: <E1FyUX2-0007Gm-00@gondolin.me.apana.org.au>
	 <1152207384.20248.104.camel@trinity.ogc.int>
	 <20060707000337.GA31273@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rdreier@cisco.com, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:46445 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1750934AbWGGAcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 20:32:39 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060707000337.GA31273@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-07-07 at 10:03 +1000, Herbert Xu wrote:
> On Thu, Jul 06, 2006 at 12:36:24PM -0500, Tom Tucker wrote:
> > 
> > The RDMA CMA uses IP addresses and port numbers to create a uniform
> > addressing scheme across all transport types. For IB, it is necessary to
> > resolve IP addresses to IB GIDs. The ARP protocol is used to do this and
> > a netfilter rule is installed to snoop the incoming ARP replies. This
> > would not be necessary if ARP events were provided as in the patch. 
> 
> Well the concerns we have do not apply to just iWARP, but RDMA/IP in
> general so this isn't really another technology.
> 
> In fact, it seems that we now have IP-specific knowledge living in
> drivers/infiniband/core/cma.c which is suboptimal.

To be clear the CMA doesn't look in the ARP packet, it just uses the
existence of the packet as an indication that it should check to see if
the ARP request it submitted for an IP address has been resolved yet. I
agree that this is suboptimal and why I think the notifier is a nice
alternative. 

> 
> > Unified wire iSCSI adapters have the same issue as iWARP wrt to managing
> > IP addresses and ports.
> 
> If by Unified wire iSCSI you mean something that presents a SCSI interface
> together with an Ethernet interface where the two share the same MAC and
> IP address, 

Yes, this is what I mean. But the notifier doesn't actually support
this, you would need to expose the IP/port space database to solve that
problem.

What I was referring to relative to  iSCSI is if the adapter is relying
on Linux to do ARP via the above suboptimal implementation, then it
would benefit from the notifier patch.

> then we have the same concerns with it as we do with iWARP or
> TOE.

Yes indeed.

> 
> Cheers,




