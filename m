From: Dan Williams <dcbw@redhat.com>
Subject: Re: [git patches] net driver fixes
Date: Fri, 14 Sep 2007 16:11:57 -0400
Message-ID: <1189800717.20386.13.camel@xo-3E-67-34.localdomain>
References: <20070913053022.GA16891@havoc.gtf.org>
	 <1189793598.2508.4.camel@xo-3E-67-34.localdomain>
	 <46EAD049.4020107@garzik.org>
	 <1189794677.2508.19.camel@xo-3E-67-34.localdomain> <32620.1189797572@death>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57844 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755068AbXINUNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 16:13:30 -0400
In-Reply-To: <32620.1189797572@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-09-14 at 12:19 -0700, Jay Vosburgh wrote:
> Dan Williams <dcbw@redhat.com> wrote:
> [...]
> >I admit that I probably don't understand the system architecture of
> >where ehea would be used, but would this
> >cause /sys/class/net/ethX/carrier to be TRUE even if the device has no
> >carrier?  That seems quite wrong IMHO.  When does ehea not have a
> >carrier?  And in that case, does sysfs say 1 or 0 for the carrier?
> 
> 	I don't work on ehea, but I'm generally familiar with it, and
> particularly with this patch.
> 
> 	The usual environment for ehea devices is on large systems
> subdivided into multiple logical partitions.  One ehea device serves
> many partitions.  By having ehea always report "link up" to the logical
> ports (the ports seen by the partitions), the partitions can communicate
> amongst themselves even if the external ports (the ports that go to the
> switch or whatever) have no link.  

(forgive my ignorance of course)

So essentially the ehea device has a 1(+) external ports that may/may
not be connected, but all lpars share the physical hardware itself,
which is quite happy to let all the lpars talk to each other essentially
via loopback even if there is no actual carrier detected on the external
port(s)?  How does addressing work here, is it just L2 addresses?  Feel
free to point me to some docs and tell me to shut up :)

At least these days module parameters can be changed at runtime through
sysfs.  Stuff that can only be set at module load doesn't provide
userspace the flexibility it needs to configure stuff on the fly.

Dan

> 	The ehea device, more or less, acts as a switch connecting the
> partitions together.  This switch type of functionality is not dependent
> upon the link state of the external ports (any more than the
> functionality of any switch is dependent upon whether or not it is
> connected to a gateway).
> 
> 	This, if I'm not mistaken, is the way ehea has always operated
> until this particular patch was added.
> 
> 	This patch (to optionally pass carrier state to the logical
> ports) was added largely for bonding, so that the bonding driver can
> detect link failures on the external ports (when so desired).  The
> default behavior remains the original behavior, i.e., do not pass
> external port link state to the logical ports.
> 
> 	Anyway, to answer your question, the carrier state reported for
> the ehea interface on the partition will always be true.  Think of it as
> reporting the link state from the logical interface to the "switch" that
> connects the partitions; that link exists only within the ehea device
> itself, and really can't fail unless the ehea device itself fails.
> 
> 	With the new option enabled, then ehea is more or less mimicing
> a trunk failover type of function, and passing the carrier state of the
> "external switch port" to the internal port.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

