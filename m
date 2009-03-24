From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 14:22:25 -0500
Message-ID: <20090324192225.GC22700@auslistsprd01.us.dell.com>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com> <alpine.DEB.1.10.0903241140530.16753@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: david@lang.hm
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903241140530.16753@asgard.lang.hm>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 24, 2009 at 11:49:26AM -0700, david@lang.hm wrote:
> On Tue, 24 Mar 2009, Matt Domsch wrote:
> 
> >You may recall http://lkml.org/lkml/2006/9/29/268, wherein I described
> >network device enumeration and naming challenges, and several possible
> >fixes.  Of these, Fix #1 (fix the PCI device list to be sorted
> >breadth-first) has been implemented in the kernel, and Fix #3 (system
> >board routing rules) have been implemented on Dell PowerEdge 10G and
> >11G servers (11G begin selling RSN).
> >
> >However, these have not been completely satisfactory.  In particular,
> >it keeps getting harder and harder to route PCI-Express lanes to
> >guarantee the same ordering between a depth-first and breadth-first
> >walk, and it turns out, that isn't sufficient anyhow.
> >
> >
> >Problem:  Users expect on-motherboard NICs to be named eth0..ethN.  This 
> >can be difficult to achieve.
> 
> I dispute this statement.
> 
> I have several hundred servers that have the on-motherboard NICs as the 
> last ones.
> 
> anyone who's been making the assumption you describe will have been 
> running into problems for many years.
> 
> it's just not a valid assumption.

I agree it's not a valid assumption.

People seem to want two things with names:
1) that devices be named deterministically
2) that the determinism doesn't change on a per-platform or
   per-configuration-of-a-platform basis.

This tends to mean they want the onboard devices named first, then the
add-in devices named.  But not necessarily.  I would hope to have a
deterministic naming method that would work for most people by
default, but that could be changed (in userspace) as necessary.

> >4) When adding a network card to an existing system, what should the
> >  ports on the new card be named?  If it is added, they will be named
> >  ethN+1... above the existing named cards.  This means a (new)
> >  add-in card in PCI slot 3 may have ports named eth5 and eth6, while
> >  an add-in card in PCI slot 5 may have ports named eth2 and eth3.
> >  This is not intuitive.
> 
> this approach causes serious problems in a few cases, including
> 
> 1. a NIC goes bad and you replace it. now all the configs change
> 
> 2. you reinstall a box and it's interface names change.

Right.  These cases are only deterministic because they start from a
known state; change or remove that state, and you're back to
non-deterministic.

-- 
Matt Domsch
Linux Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
