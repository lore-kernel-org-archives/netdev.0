From: Mark Huth <mhuth@mvista.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating master's
  settings toslaves
Date: Mon, 11 Aug 2003 14:27:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F380A28.10902@mvista.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com> <200308111720.38472.shmulik.hen@intel.com> <1060612481.1034.15.camel@jzny.localdomain> <200308111925.38278.shmulik.hen@intel.com> <3F37C7C3.7070807@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shmulik.hen@intel.com, hadi@cyberus.ca,
   Laurent DENIEL
 <laurent.deniel@thalesatm.com>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Jeff Garzik wrote:

> The answer is, like life, it's a balance.
>
> As a general rule, we do prefer to move all code possible out of the 
> Linux kernel.  We have even created "initramfs", which for 2.7, will 
> be used as a vehicle to move code from the kernel to userspace, that 
> previously had to be in the kernel only because it was a task that 
> "had to be performed at boot time".
>
> However, one must consider
> (1) does moving code to userspace create any security holes?
> (2) does moving code to userspace dramatically increase the number of 
> context switches?
> (3) does moving code to userspace violate some atomicity that being 
> inside the kernel guarantees?
>
> In practice, #3 is the showstopper that occurs most often.
>
> This is why I push for a "bonding-utils" package from Jay.... because 
> of the general rule above:  put it into userspace, where possible.
>
>     Jeff

Yes, the answer is balance - the complicated, but non-time critical 
things should go into applications.  However, we need to retain a basic 
ability to perform the failover according to pre-configured rules within 
the kernel.  Many of our customers use bonding to provide a redundant 
network path through the wires and switches for what turn out to be 
heavily network dependant applications.  In many cases, the systems do 
not have a local disk, and everything is obtained via say an NFS mount. 
 When the MAC breaks, you may not be able to run userland!

In HA systems at this level, guarding against the failure of a redundant 
hardware component, we find that it is very helpful for the kernel to be 
able to perform a variety of simple, pre-programmed operations without 
resort to userland - this keeps the interacting fault domains smaller. 
 Sure, the decisons about how to configure the behaviors - that is the 
policies - belong in applications.  But the response to an event which 
triggers the actions may well _need_ to be in the kernel.

While the issue may not be so much one of speed - the applications may 
well respond in an adequate manner, depending on design and load - the 
issue of the amount of the system that must work for recovery is quite 
important when trying to push system availabilities into the mythical 5 
9's plus region.  For an application to run, the system has to be able 
to fork and exec, access the file system, allocate memory, etc.  Sure, 
through careful configuration it is possible to reduce the transient 
resources required (run a pre-loaded/locked daemon, make sure the files 
are locally cached, etc) then the configuration and testing are 
complicated.  It worked fine in the lab, because a resource we didn't 
realize was critical, never got pushed out of the dcache, for example.

Mark Huth
