From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Thu, 15 Jul 2004 23:20:35 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715232035.37e016ef@zanzibar.2ka.mipt.ru>
References: <1089898303.6114.859.camel@uganda>
	<1089898595.6114.866.camel@uganda>
	<1089902654.1029.23.camel@jzny.localdomain>
	<1089905244.6114.887.camel@uganda>
	<1089906936.6114.904.camel@uganda>
	<1089908900.1027.77.camel@jzny.localdomain>
	<1089910757.6114.965.camel@uganda>
	<1089912658.1029.101.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1089912658.1029.101.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 15 Jul 2004 13:30:59 -0400
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2004-07-15 at 12:59, Evgeniy Polyakov wrote:
> > On Thu, 2004-07-15 at 20:28, jamal wrote:
> 
> > > Easy with current traffic control extensions. We need an action
> > > written for this. User space dameon controls it.
> > 
> > Load balancing between different computers?
> > How nodes will know about each other using only tc extension?
> 
> Why do they need to know about each other. Maybe explain a little
> how said load balancing is achieved.

Kind of scuch scenario:
If I am a masater, than get half of bandwidth, but if slave count is
less than threshold than get more.
If I am a slave and slave count is more than threshold than get
0.5/slave_count of the bandwidth and reserve some else get...

> > Kernel traps packet, send info about it to userspace, it decides
> > drop it or not... Not very fast path.
> 
> I am hoping CARP knows how to deal with dropped packets.

Tssss, OpenBSD's one just silently drops.
Linux one will (if will) use some clever mechanism to be sure that
someone got this packet and _I_ may drop it.

> > Or you may hardcode parameters for packets to be sent through
> > current machine in it's rules, and userspace will decide only _when_
> > apply all those rules. But if we want to change things we have
> > following chain: driver <-0-> stack <-1-> tc <-2-> userspace carp
> > <-3-> stack <-4-> other machine.
> > With kernel implementation we may avoid 2 and 3.
> 
> use socket to send to user space. When you want to install a load
> balancing rule, use netlink from user space to the kernel.
> Loadbalancing resides in the kernel as a tc action.

What about case when you do need kernel space access based on CARP
state?
You will need to install each time new kernel agent for it.
With CARP being implemented in kernelspace you need just one - CARP
itself.

> > And the bigggest advantage of the CARP is that it may touch kernel
> > bits. For any situation that may occure in HA world and will require
> > touching kernel space we always need some inkernel agent and some
> > state machine/protocol to connect it to userspace...
> > CARP already may this.
> 
> weak arguement, I am afraid. I am looking at the way the BSD people
> did it - which is what you are emulating and it is wrong. No need for
> this stuff to be done in kernel at all.

No. BSD people have kernel implementation: OpenBSD has, FreeBSD has
port, NetBSD has port, but not included into mainline due to patent
issue.

It is case of abstraction: for some reason(and for most of all) you do
not need kernel space implmentation.
But reasons do exist to use it in kernel space, and if it will become an
issue some day, you will anyway create a kernel agent. If you need
kernel access in HA system, do not create new agents, just use CARP as
kernel agent and arbiter.

> 
> cheers,
> jamal


	Evgeniy Polyakov ( s0mbre )

Only failure makes us experts. -- Theo de Raadt
