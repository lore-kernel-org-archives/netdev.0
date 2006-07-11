From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: What is RDMA (was: RDMA will be reverted)
Date: Tue, 11 Jul 2006 08:27:21 -0500
Message-ID: <1152624441.28478.6.camel@stevo-desktop>
References: <adaac7naj80.fsf@cisco.com>
	 <20060705.200325.74731166.davem@davemloft.net>
	 <1152163503.20248.98.camel@trinity.ogc.int>
	 <20060706.235320.92562667.davem@davemloft.net>
	 <20060707081131.GA2991@gondor.apana.org.au>
	 <1152296744.18332.42.camel@stevo-desktop>
	 <20060711081725.GD1490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tom@opengridcomputing.com,
	rdreier@cisco.com, netdev@vger.kernel.org, akpm@osdl.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [67.65.19.105] ([67.65.19.105]:61469 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1750757AbWGKN3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 09:29:17 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060711081725.GD1490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-07-11 at 18:17 +1000, Herbert Xu wrote:
> On Fri, Jul 07, 2006 at 01:25:44PM -0500, Steve Wise wrote:
> > 
> > Some IP networking is involved for this.  IP addresses and port numbers
> > are used by the RDMA Connection Manager.  The motivation for this was
> > two-fold, I think:
> > 
> > 1) to simplify the connection setup model.  The IB CM model was very
> > complex.
> > 
> > 2) to allow ULPs to be transport independent.  Thus a single code base
> > for NFSoRDMA, for example, can run over Infiniband and RDMA/TCP
> > transports without code changes or knowing about transport-specific
> > addressing.
> > 
> > The routing table is also consulted to determine which rdma device
> > should be used for connection setup.  Each rdma device also installs a
> > netdev device for native stack traffic.  The RDMA CM maintains an
> > association between the netdev device and the rdma device.  
> > 
> > And the Infiniband subsystem uses ARP over IPoIB to map IP addresses to
> > GID/QPN info.  This is done by calling arp_send() directly, and snooping
> > all ARP packets to "discover" when the arp entry is completed.
> 
> This sounds interesting.
> 
> Since this is going to be IB-neutral, what about moving high-level logic
> like this is moved out of drivers/infiniband and into net?
> 
> That way the rest of the networking community can add input into how
> things are done.
> 

The notifier patch I posted sort of does this already by eliminating the
need to snoop arp replies.  It will notify interested subsystems of
neighbour changes (EG when an ARP reply is processed and the neighbour
struct updated with the correct hw mac addr).  And I _think_
neigh_event_send() could be used instead of arp_send().


Steve.

