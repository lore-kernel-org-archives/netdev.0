From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Fri, 23 Jun 2006 08:11:51 -0500
Message-ID: <1151068311.7808.8.camel@stevo-desktop>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
	 <20060622.015728.59653992.davem@davemloft.net>
	 <1150984380.27156.4.camel@stevo-desktop>
	 <1150990041.3040.6.camel@stevo-desktop>  <1151005381.5392.108.camel@jzny2>
	 <1151007524.3040.48.camel@stevo-desktop>  <1151008597.5392.118.camel@jzny2>
	 <1151009932.3040.80.camel@stevo-desktop>  <1151014488.5099.23.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:44610 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S964816AbWFWNLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 09:11:53 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151014488.5099.23.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > 
> > > Out of curiosity - what does RDMA NIC have that would need these events?
> > > a route table or L2 table etc? Can you elucidate a little?
> > > 
> > 
> > Mainly the L2 table, next hop ip addr, and the path mtu.  RDMA NICs
> > implement the entire RDMA stack in HW.  How they deal with L2 and L3
> > changes vary to some degree, but what seems to be emerging is that they
> > get this information from the native stack because ARP and ICMP, for
> > example, are always passed up to the native stack.
> > 
> 
> I am still unclear: 
> You have destination IP address, the dstMAC of the nexthop to get the
> packet to this IP address and i suspect some srcMAC address you will use
> sending out as well as the pathMTU to get there correct?
> Because of the IP address it sounds to me like you are populating an L3
> table

I mispoke.  The HW I'm using really only maintains a table of next hop
mac addrs and a table of src mac addrs.  Each active RDMA connection in
HW keeps an index into each table for building the ethernet header. 

The _driver_ needs to know when the next hop mac addr changes, or when
the next hop itself changes for a given destination so that it can
update the active connections and/or the L2T table accordingly.   Same
deal with the path mtu...

> How is this info used in hardware? Can you explain how an arriving
> packet would be used by the RDMA in conjunction with this info once it
> is in the hardware?
> 

I think my stuff above explains this, eh?

> > These devices also act a standard Ethernet NIC btw...
> > 
> 
> Meaning there is no funky hardware processing?
> 

If an incoming packet is not for one of the active RDMA connections (or
a listening RDMA endpoint), then the packet is passed up to the native
stack via the device's netdev driver.

Stevo.


