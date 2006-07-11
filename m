From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: What is RDMA (was: RDMA will be reverted)
Date: Tue, 11 Jul 2006 18:17:25 +1000
Message-ID: <20060711081725.GD1490@gondor.apana.org.au>
References: <adaac7naj80.fsf@cisco.com> <20060705.200325.74731166.davem@davemloft.net> <1152163503.20248.98.camel@trinity.ogc.int> <20060706.235320.92562667.davem@davemloft.net> <20060707081131.GA2991@gondor.apana.org.au> <1152296744.18332.42.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tom@opengridcomputing.com,
	rdreier@cisco.com, netdev@vger.kernel.org, akpm@osdl.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:10765 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750729AbWGKITH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 04:19:07 -0400
To: Steve Wise <swise@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <1152296744.18332.42.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2006 at 01:25:44PM -0500, Steve Wise wrote:
> 
> Some IP networking is involved for this.  IP addresses and port numbers
> are used by the RDMA Connection Manager.  The motivation for this was
> two-fold, I think:
> 
> 1) to simplify the connection setup model.  The IB CM model was very
> complex.
> 
> 2) to allow ULPs to be transport independent.  Thus a single code base
> for NFSoRDMA, for example, can run over Infiniband and RDMA/TCP
> transports without code changes or knowing about transport-specific
> addressing.
> 
> The routing table is also consulted to determine which rdma device
> should be used for connection setup.  Each rdma device also installs a
> netdev device for native stack traffic.  The RDMA CM maintains an
> association between the netdev device and the rdma device.  
> 
> And the Infiniband subsystem uses ARP over IPoIB to map IP addresses to
> GID/QPN info.  This is done by calling arp_send() directly, and snooping
> all ARP packets to "discover" when the arp entry is completed.

This sounds interesting.

Since this is going to be IB-neutral, what about moving high-level logic
like this is moved out of drivers/infiniband and into net?

That way the rest of the networking community can add input into how
things are done.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
