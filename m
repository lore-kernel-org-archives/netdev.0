From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [Alacrityvm-devel] [GIT PULL] AlacrityVM guest drivers for
 2.6.33
Date: Wed, 23 Dec 2009 11:54:13 -0800
Message-ID: <20091223195413.GB30700@ovro.caltech.edu>
References: <4B1D4F29.8020309@gmail.com>
 <20091218215107.GA14946@elte.hu>
 <4B2F9582.5000002@gmail.com>
 <20091222075742.GB26467@elte.hu>
 <4B3103B4.4070708@gmail.com>
 <f73f7ab80912222215i39ba865dv95764f95fd57bd96@mail.gmail.com>
 <4B3232A1.8050505@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle Moffett <kyle@moffetthome.net>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	torvalds@linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756976AbZLWTyY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B3232A1.8050505@codemonkey.ws>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2009 at 09:09:21AM -0600, Anthony Liguori wrote:
> On 12/23/2009 12:15 AM, Kyle Moffett wrote:
> > This is actually something that is of particular interest to me.  I
> > have a few prototype boards right now with programmable PCI-E
> > host/device links on them; one of my long-term plans is to finagle
> > vbus into providing multiple "virtual" devices across that single
> > PCI-E interface.
> >
> > Specifically, I want to be able to provide virtual NIC(s), serial
> > ports and serial consoles, virtual block storage, and possibly other
> > kinds of interfaces.  My big problem with existing virtio right now
> > (although I would be happy to be proven wrong) is that it seems to
> > need some sort of out-of-band communication channel for setting up
> > devices, not to mention it seems to need one PCI device per virtual
> > device.
> 
> We've been thinking about doing a virtio-over-IP mechanism such that you 
> could remote the entire virtio bus to a separate physical machine. 
> virtio-over-IB is probably more interesting since you can make use of 
> RDMA. virtio-over-PCI-e would work just as well.
> 

I didn't know you were interested in this as well. See my later reply to
Kyle for a lot of code that I've written with this in mind.

> virtio is a layered architecture.  Device enumeration/discovery sits at 
> a lower level than the actual device ABIs.  The device ABIs are 
> implemented on top of a bulk data transfer API.  The reason for this 
> layering is so that we can reuse PCI as an enumeration/discovery 
> mechanism.  This tremendenously simplifies porting drivers to other OSes 
> and let's us use PCI hotplug automatically.  We get integration into all 
> the fancy userspace hotplug support for free.
> 
> But both virtio-lguest and virtio-s390 use in-band enumeration and 
> discovery since they do not have support for PCI on either platform.
> 

I'm interested in the same thing, just over PCI. The only PCI agent
systems I've used are not capable of manipulating the PCI configuration
space in such a way that virtio-pci is usable on them. This means
creating your own enumeration mechanism. Which sucks. See my virtio-phys
code (http://www.mmarray.org/~iws/virtio-phys/) for an example of how I
did it. It was modeled on lguest. Help is appreciated.

Ira
