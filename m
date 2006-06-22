From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 18:14:48 -0400
Message-ID: <1151014488.5099.23.camel@jzny2>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
	 <20060622.015728.59653992.davem@davemloft.net>
	 <1150984380.27156.4.camel@stevo-desktop>
	 <1150990041.3040.6.camel@stevo-desktop>  <1151005381.5392.108.camel@jzny2>
	 <1151007524.3040.48.camel@stevo-desktop>  <1151008597.5392.118.camel@jzny2>
	 <1151009932.3040.80.camel@stevo-desktop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:18903 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1161361AbWFVWOv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 18:14:51 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FtXRw-0001ZO-0o
	for netdev@vger.kernel.org; Thu, 22 Jun 2006 18:14:56 -0400
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <1151009932.3040.80.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-22-06 at 15:58 -0500, Steve Wise wrote:
> On Thu, 2006-06-22 at 16:36 -0400, jamal wrote:

> I created a new notifier block in my patch for these network events.   I
> guess I thought I was using the existing infrastructure to provide this
> notification service. (I thought my patch was lovely :)  But I didn't
> integrate with netlink for user space notification. Mainly cuz I didn't
> think these events should be propagated up to users unless there was a
> need.  

I think they will be useful in user space. Typically you only propagate
them if there's a user space program subscribed to listening (there are
hooks which will tell you if there's anyone listening).
The netdevice events tend to be a lot more usable in a few other blocks
because they are lower in the hierachy (i.e routing depends on ip
addresses which depend on netdevices) within the kernel unlike in this
case where you are the only consumer; so it does sound logical to me
to do it in user space; however, not totally unreasonable to do it in
the kernel.

> Just to clarify, you're suggesting I add any needed netlink hooks for
> rt_redirect and the others that don't exist today, and use a NETLINK
> socket in user space to discover these events.  Yes?
> 

indeed.

> > Your mileage may vary. If you do it in user space you dont have to wait
> > for the next kernel release in case of a bug. 
> 
> As long as all the events are passed up correctly :-)
> 

They have been for years ;-> 

> > Additionally, it allows
> > for more feature richness that would tend to bloat the kernel/infiniband
> > otherwise. 
> 
> 
> Another issue I see with netlink is that the event notifications aren't
> reliable.  Especially the CONFIG_ARPD stuff because it allocs an sk_buff
> with ATOMIC.  A lost neighbour macaddr change is perhaps fatal for an
> RDMA connection...
> 

This would happen in the cases where you are short on memory; i would
suspect you will need to allocate memory in your driver as well to
update something in the hardware as well - so same problem.
You can however work around issues like these in netlink.

> 
> > Out of curiosity - what does RDMA NIC have that would need these events?
> > a route table or L2 table etc? Can you elucidate a little?
> > 
> 
> Mainly the L2 table, next hop ip addr, and the path mtu.  RDMA NICs
> implement the entire RDMA stack in HW.  How they deal with L2 and L3
> changes vary to some degree, but what seems to be emerging is that they
> get this information from the native stack because ARP and ICMP, for
> example, are always passed up to the native stack.
> 

I am still unclear: 
You have destination IP address, the dstMAC of the nexthop to get the
packet to this IP address and i suspect some srcMAC address you will use
sending out as well as the pathMTU to get there correct?
Because of the IP address it sounds to me like you are populating an L3
table
How is this info used in hardware? Can you explain how an arriving
packet would be used by the RDMA in conjunction with this info once it
is in the hardware?

> These devices also act a standard Ethernet NIC btw...
> 

Meaning there is no funky hardware processing?

cheers,
jamal


