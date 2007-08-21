From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports from the host TCP port space.
Date: Mon, 20 Aug 2007 18:16:54 -0700
Message-ID: <adalkc5u1o9.fsf@cisco.com>
References: <adafy2hyc04.fsf@cisco.com>
	<20070817.170033.63993876.davem@davemloft.net>
	<adatzqxwh56.fsf@cisco.com>
	<20070817.234405.66176298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@opengridcomputing.com, jeff@garzik.org,
	swise@opengridcomputing.com, mshefty@ichips.intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2-in.cisco.com ([171.71.176.71]:12670 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbXHUBQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 21:16:56 -0400
In-Reply-To: <20070817.234405.66176298.davem@davemloft.net> (David Miller's message of "Fri, 17 Aug 2007 23:44:05 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TSO / LRO discussion snipped -- it's not the main point so no sense
spending energy arguing about it]

 > Just be realistic and accept that RDMA is a point in time solution,
 > and like any other such technology takes flexibility away from users.
 > 
 > Horizontal scaling of cpus up to huge arity cores, network devices
 > using large numbers of transmit and receive queues and classification
 > based queue selection, are all going to work to make things like RDMA
 > even more irrelevant than they already are.

To me there is a real fundamental difference between RDMA and
traditional SOCK_STREAM / SOCK_DATAGRAM networking, namely that
messages can carry the address where they're supposed to be
delivered (what the IETF calls "direct data placement").  And on top
of that you can build one-sided operations aka put/get aka RDMA.

And direct data placement really does give you a factor of two at
least, because otherwise you're stuck receiving the data in one
buffer, looking at some of the data at least, and then figuring out
where to copy it.  And memory bandwidth is if anything becoming more
valuable; maybe LRO + header splitting + page remapping tricks can get
you somewhere but as NCPUS grows then it seems the TLB shootdown cost
of page flipping is only going to get worse.

Don't get too hung up on the fact that current iWARP (RDMA over IP)
implementations are using TCP offload -- to me that is just a side
effect of doing enough processing on the NIC side of the PCI bus to be
able to do direct data placement.  InfiniBand with competely different
transport, link and physical layers is one way to implement RDMA
without TCP offload and I'm sure there will be others -- eg Intel's
IOAT stuff could probably evolve to the point where you could
implement iWARP with software TCP and the data placement offloaded to
some DMA engine.

 - R.
