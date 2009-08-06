From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 6 Aug 2009 16:23:36 -0700
Message-ID: <20090806232335.GC20758@ovro.caltech.edu>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <4A7AE150.7040009@redhat.com> <4A7AAB1A0200005A00051BED@sinclair.provo.novell.com> <200908061740.04276.arnd@arndb.de> <4A7ACC940200005A00051C43@sinclair.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	alacrityvm-devel@lists.sourceforge.net,
	Avi Kivity <avi@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:43807 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932191AbZHFXXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 19:23:36 -0400
Content-Disposition: inline
In-Reply-To: <4A7ACC940200005A00051C43@sinclair.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 06, 2009 at 10:29:08AM -0600, Gregory Haskins wrote:
> >>> On 8/6/2009 at 11:40 AM, in message <200908061740.04276.arnd@arndb.de>, Arnd
> Bergmann <arnd@arndb.de> wrote: 
> > On Thursday 06 August 2009, Gregory Haskins wrote:

[ big snip ]

> > 
> > 3. The ioq method seems to be the real core of your work that makes
> > venet perform better than virtio-net with its virtqueues. I don't see
> > any reason to doubt that your claim is correct. My conclusion from
> > this would be to add support for ioq to virtio devices, alongside
> > virtqueues, but to leave out the extra bus_type and probing method.
> 
> While I appreciate the sentiment, I doubt that is actually whats helping here.
> 
> There are a variety of factors that I poured into venet/vbus that I think contribute to its superior performance.  However, the difference in the ring design I do not think is one if them.  In fact, in many ways I think Rusty's design might turn out to be faster if put side by side because he was much more careful with cacheline alignment than I was.  Also note that I was careful to not pick one ring vs the other ;)  They both should work.

IMO, the virtio vring design is very well thought out. I found it
relatively easy to port to a host+blade setup, and run virtio-net over a
physical PCI bus, connecting two physical CPUs.

> 
> IMO, we are only looking at the tip of the iceberg when looking at this purely as the difference between virtio-pci vs virtio-vbus, or venet vs virtio-net.
> 
> Really, the big thing I am working on here is the host side device-model.  The idea here was to design a bus model that was conducive to high performance, software to software IO that would work in a variety of environments (that may or may not have PCI).  KVM is one such environment, but I also have people looking at building other types of containers, and even physical systems (host+blade kind of setups).
> 
> The idea is that the "connector" is modular, and then something like virtio-net or venet "just work": in kvm, in the userspace container, on the blade system. 
> 
> It provides a management infrastructure that (hopefully) makes sense for these different types of containers, regardless of whether they have PCI, QEMU, etc (e.g. things that are inherent to KVM, but not others).
> 
> I hope this helps to clarify the project :)
> 

I think this is the major benefit of vbus. I've only started studying
the vbus code, so I don't have lots to say yet. The overview of the
management interface makes it look pretty good.

Getting two virtio-net drivers hooked together in my virtio-over-PCI
patches was nasty. If you read the thread that followed, you'll see
the lack of a management interface as a concern of mine. It was
basically decided that it could come "later". The configfs interface
vbus provides is pretty nice, IMO.

Just my two cents,
Ira
