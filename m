From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and
	statistics via rtnetlink
Date: Tue, 31 May 2005 08:48:30 -0400
Message-ID: <1117543711.6134.48.camel@localhost.localdomain>
References: <20050527121503.GN15391@postel.suug.ch>
	 <1117201853.6383.29.camel@localhost.localdomain>
	 <20050527141023.GP15391@postel.suug.ch>
	 <1117205822.6383.68.camel@localhost.localdomain>
	 <20050527151608.GZ15391@postel.suug.ch>
	 <1117209411.6383.104.camel@localhost.localdomain>
	 <20050527163516.GB15391@postel.suug.ch>
	 <1117244567.6251.34.camel@localhost.localdomain>
	 <20050528120731.GP15391@postel.suug.ch>
	 <1117533847.6134.32.camel@localhost.localdomain>
	 <20050531114251.GC15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050531114251.GC15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-31-05 at 13:42 +0200, Thomas Graf wrote:

> > All "stuffs" (your bases is mine) accessible via in_devxx abstraction
> > should be devconfig configurable. I do concur that some of it may not
> > make sense - but that should be the exception rules...
> > Ok, lets say these tables are one such exception, but note:
> > In the future there could be multiple ARP tables for example (very
> > likely given all the virtualization approaches happening). In other
> > words different devices may point to different tables...
> 
> Let's assume for a moment that there are no device specific parameters,
> just the default parameter set, e.g everything in the "arp_cache" block.
> According do your idea, everything would be part of a faked in_dev entry
> with ifindex==0 (or alike). We'd have the exact same issues as with
> RTM_NEIGHTBL, the requirement of unique table ids stays the same. There
> is one big difference though, what if we ever have neighbour tables which
> do not care about inet devices at all? Maybe some kind of new virtual
> devices for in-kernel communication? ;-> Sounds scary and not realistic,

An extra virtual device just to store the defaults will be overkill.
OTOH, a global allocated structure for defaults is ok. I think thats the
way it is done today.

> but my point is basically that neighbour tables itself have a global scope,
> the assignment to the device and device specific parameters is on the
> level of the neighbours itself. The connection to in_dev/... is one
> level higher with a scope of the relevant neighbour table. A neighbour
> table implementation is not required to support device specific
> parameters, the code neighbour code will always assign the default
> parameter set and leaves it up to the constructor of the implementation
> level to reassign a device specific parameter set. Which means that what
> the procfs and now also neightbl code does it kind of a hack anyway
> since the core neighbour code is not aware of device specific stuff
> anyway, all it does is provide an easy method to manage them in a
> efficient matter.  

The neighbor code ought not be aware of devices; but whoever is
configuring must be. By configuring i mean "stiching together" the
different blocks (as in some netlink based program in user space). the
idevxxx is a "stiching"  construct - and therefore it may be aware of
many other things that a standalone block doesnt. One could argue that
the ifindex in a netdevice is also under the same class. The ARP, NDISC,
netdevice, filters etc are the blocks being sown together. 
Most of the times these blocks are built together in a topology that a
packet flows through. 

> I would like to stay consistent to this architecture
> if possible to be able to follow every new additions.
> 
> I hope my point is now clear, I wasn't so sure until now ;-> However,
> I think you have a good point, parameter sets have a strong relation
> to inet devices at the moment. If you still think that we should move
> _everything_ into a devconfig layer then I'll do it but I still support
> my initial prospoal.
> 

I agree that we should leave the neighbor table-specific knobs out of
devconfig.  
It will help, though, for devconfig to have a single reference to the
"instance" of the table(perhaps a name or a even a 32 bit pointer
address) that a device uses (thefore maintaining the abstraction); but
since there is only one table for v4 and v6 anyways i suppose it is
implicitly assumed to be that one table.

cheers,
jamal
