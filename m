From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH net 1/4] pegasus: Use heap buffers for all register access
Date: Wed, 8 Feb 2017 09:57:36 +0200
Message-ID: <20170208075736.clhgooyed5rvr3ng@p310>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165603.GV3442@decadent.org.uk>
 <20170205003038.GB21184@kroah.com>
 <20170206081444.smcgjkmdepxoosb6@p310>
 <20170206082822.GA23451@kroah.com>
 <20170206125108.d5vdur5rlvrkpr5j@localhost>
 <CAJJ6jxt-47saW=B260j0v_Gdt-dwb4YepRZTWQ-nYfLBGQUT=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Ben Hutchings <ben@decadent.org.uk>,
        netdev@vger.kernel.org, USB list <linux-usb@vger.kernel.org>,
        Lisandro =?utf-8?Q?Dami=C3=A1n_Nicanor_P=C3=A9rez?= Meyer
        <lisandro@debian.org>
To: Steve Calfee <stevecalfee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:37524 "EHLO
        zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752061AbdBHH6R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 02:58:17 -0500
Content-Disposition: inline
In-Reply-To: <CAJJ6jxt-47saW=B260j0v_Gdt-dwb4YepRZTWQ-nYfLBGQUT=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-07 10:32:16, Steve Calfee wrote:
> On Mon, Feb 6, 2017 at 4:51 AM, Petko Manolov <petkan@nucleusys.com> wrote:
> > On 17-02-06 09:28:22, Greg KH wrote:
> >> On Mon, Feb 06, 2017 at 10:14:44AM +0200, Petko Manolov wrote:
> >> > On 17-02-05 01:30:39, Greg KH wrote:
> >> > > On Sat, Feb 04, 2017 at 04:56:03PM +0000, Ben Hutchings wrote:
> >> > > > Allocating USB buffers on the stack is not portable, and no longer works
> >> > > > on x86_64 (with VMAP_STACK enabled as per default).
> >> > >
> >> > > It's never worked on other platforms, so these should go to the stable
> >> > > releases please.
> >> >
> >> > As far as i know both drivers works fine on other platforms, though I only
> >> > tested it on arm and mipsel. ;)
> >>
> >> It all depends on the arm and mips platforms, the ones that can not DMA 
> >> from stack memory are the ones that would always fail here (since the 2.2 
> >> kernel days).
> >
> > Seems like most modern SOCs have decent DMA controllers.
> >
> 
> The real problem is not DMA exactly, it is cache coherency.
> 
> X86 has a coherent cache and all the cpu cores watch DMA transfers and keep 
> the cpu caches up to date.

Yep, these cpus are more user friendly.

> Most ARMs and MIPS processors have incoherent cache, so DMA can change memory 
> without the CPU cache updates. CPU cache view of what is in memory can be 
> different from what was DMAed in, this makes failures very hard to detect, 
> reproduce and racy.

Except for a very few purposes (like framebuffer memory) one should be crazy to 
use anything but kseg1 for accessing the peripherals.  One of the real problems 
here is the 512MB limit of the uncached segment.  While the DMA controller can 
typically access all available RAM you'll run into the issues that you describe 
with more than that amount of memory.

MIPS like doing things small and simple.  Everybody knows that software can 
compensate for hardware omissions. ;)

> So all DMA buffers should always be separate allocations from the stack AND 
> not be embedded in structs. Memory allocations are always at least cache line 
> aligned, so coherency is not a problem.

I do agree.


cheers,
Petko
