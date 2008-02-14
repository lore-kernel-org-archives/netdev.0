From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Thu, 14 Feb 2008 09:36:15 -0800
Message-ID: <1203010575.12312.6.camel@dyn9047017100.beaverton.ibm.com>
References: <200802111724.12416.ossthema@de.ibm.com>
	 <1202748429.8276.21.camel@nimitz.home.sr71.net>
	 <200802131617.58646.ossthema@de.ibm.com>
	 <OF64B9886B.CE795DED-ONC12573EF.002FFA8B-C12573EF.00301683@de.ibm.com>
	 <1203009163.19205.42.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <RAISCH@de.ibm.com>, ossthema@linux.vnet.ibm.com,
	apw <apw@uk.ibm.com>, Greg KH <greg@kroah.com>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, netdev <netdev@vger.kernel.org>,
	Thomas Q Klein <TKLEIN@de.ibm.com>, tklein@linux.ibm.com
To: Dave Hansen <haveblue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:57108 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850AbYBNRds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 12:33:48 -0500
In-Reply-To: <1203009163.19205.42.camel@nimitz.home.sr71.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-14 at 09:12 -0800, Dave Hansen wrote:
..
> > > > - Use currently other not exported functions in kernel/resource.c, like
> > > >   walk_memory_resource (where we would still need the maximum
> > > possible number
> > > >   of pages NR_MEM_SECTIONS)
> > >
> > > It isn't the act of exporting that's the problem.  It's making sure that
> > > the exports won't be prone to abuse and that people are using them
> > > properly.  You should assume that you can export and use
> > > walk_memory_resource().
> > 
> > So this seems to come down to a basic question:
> > New hardware seems to have a tendency to get "private MMUs",
> > which need private mappings from the kernel address space into a
> > "HW defined address space with potentially unique characteristics"
> > RDMA in Openfabrics with global MR is the most prominent example heading
> > there
> 
> That's not a question. ;)
> 
> Please explain to me why walk_memory_resource() is insufficient for your
> needs.  I've now pointed it out to you at least 3 times.  

I am not sure what you are trying to do with walk_memory_resource(). The
behavior is different on ppc64. Hotplug memory usage assumes that all
the memory resources (all system memory, not just IOMEM) are represented
in /proc/iomem. Its the case with i386 and ia64. But on ppc64 is
contains ONLY iomem related. Paulus didn't want to export all the system
memory into /proc/iomem on ppc64. So I had to workaround by providing
arch-specific walk_memory_resource() function for ppc64.

Thanks,
Badari

