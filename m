From: jamal <hadi@cyberus.ca>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: 15 Jul 2004 13:30:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089912658.1029.101.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>  <1089906936.6114.904.camel@uganda>
	 <1089908900.1027.77.camel@jzny.localdomain>
	 <1089910757.6114.965.camel@uganda>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1089910757.6114.965.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-15 at 12:59, Evgeniy Polyakov wrote:
> On Thu, 2004-07-15 at 20:28, jamal wrote:

> > Easy with current traffic control extensions. We need an action written
> > for this. User space dameon controls it.
> 
> Load balancing between different computers?
> How nodes will know about each other using only tc extension?

Why do they need to know about each other. Maybe explain a little
how said load balancing is achieved.

> Kernel traps packet, send info about it to userspace, it decides drop it
> or not... Not very fast path.

I am hoping CARP knows how to deal with dropped packets.

> Or you may hardcode parameters for packets to be sent through current
> machine in it's rules, and userspace will decide only _when_ apply all
> those rules. But if we want to change things we have following chain:
> driver <-0-> stack <-1-> tc <-2-> userspace carp <-3-> stack <-4-> other
> machine.
> With kernel implementation we may avoid 2 and 3.

use socket to send to user space. When you want to install a load
balancing rule, use netlink from user space to the kernel.
Loadbalancing resides in the kernel as a tc action.

> And the bigggest advantage of the CARP is that it may touch kernel bits.
> For any situation that may occure in HA world and will require touching
> kernel space we always need some inkernel agent and some state
> machine/protocol to connect it to userspace...
> CARP already may this.

weak arguement, I am afraid. I am looking at the way the BSD people did
it - which is what you are emulating and it is wrong. No need for this
stuff to be done in kernel at all.

cheers,
jamal
