From: jamal <hadi@cyberus.ca>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: 16 Jul 2004 08:34:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089981282.1060.1293.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda> <1089906936.6114.904.camel@uganda>
	 <1089908900.1027.77.camel@jzny.localdomain>
	 <1089910757.6114.965.camel@uganda>
	 <1089912658.1029.101.camel@jzny.localdomain>
	 <20040715232035.37e016ef@zanzibar.2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20040715232035.37e016ef@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-15 at 15:20, Evgeniy Polyakov wrote:

> > > Load balancing between different computers?
> > > How nodes will know about each other using only tc extension?
> > 
> > Why do they need to know about each other. Maybe explain a little
> > how said load balancing is achieved.
> 
> Kind of scuch scenario:
> If I am a masater, than get half of bandwidth, but if slave count is
> less than threshold than get more.
> If I am a slave and slave count is more than threshold than get
> 0.5/slave_count of the bandwidth and reserve some else get...

Ok, so some controller is in charge - seems like thats something that
could be easily done in user space based on mastership transitions.

> > > Kernel traps packet, send info about it to userspace, it decides
> > > drop it or not... Not very fast path.
> > 
> > I am hoping CARP knows how to deal with dropped packets.
> 
> Tssss, OpenBSD's one just silently drops.

Ok, i wont tell ;->

> Linux one will (if will) use some clever mechanism to be sure that
> someone got this packet and _I_ may drop it.

In VRRP for example its the number of heartbeats missed that makes the
difference. Also the dead interval is valuable before a split-brain hits
the fan. So maybe one or two dropped packets is ok.


> > use socket to send to user space. When you want to install a load
> > balancing rule, use netlink from user space to the kernel.
> > Loadbalancing resides in the kernel as a tc action.
> 
> What about case when you do need kernel space access based on CARP
> state?

What kind of access? To configure something? what kind of thing?

> It is case of abstraction: for some reason(and for most of all) you do
> not need kernel space implmentation.
> But reasons do exist to use it in kernel space, and if it will become an
> issue some day, you will anyway create a kernel agent. If you need
> kernel access in HA system, do not create new agents, just use CARP as
> kernel agent and arbiter.

Iam not buying it Evgeniy, sorry ;->

BTW, I like that ARP balancing feature that CARP has. Pretty neat.
Note that it could be easily done via a tc action with user space
control.

cheers,
jamal
