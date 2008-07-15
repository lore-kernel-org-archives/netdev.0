From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Tue, 15 Jul 2008 18:18:30 -0400
Message-ID: <487D2236.9000903@garzik.org>
References: <20080429171403.GA21035@redhat.com> <48177905.4000409@garzik.org> <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org> <20080529150752.GB8247@redhat.com> <483EF385.3000103@garzik.org> <20080529184106.GB24408@redhat.com> <483EFD8F.2070407@garzik.org> <20080715184006.GA20772@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60000 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752155AbYGOWSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 18:18:49 -0400
In-Reply-To: <20080715184006.GA20772@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote:
> On Thu, May 29, 2008 at 03:01:35PM -0400, Jeff Garzik wrote:
>  > Dave Jones wrote:
>  > > On Thu, May 29, 2008 at 02:18:45PM -0400, Jeff Garzik wrote:
>  > >  > Dave Jones wrote:
>  > >  > > Make PIO/MMIO a runtime thing via a module parameter.
>  > >  > > This is needed to support devices that only work with PIO
>  > >  > > without penalising devices that work fine with MMIO in
>  > >  > > distro kernels.
>  > >  > > 
>  > >  > > Signed-off-by: Dave Jones <davej@redhat.com>
>  > >  > 
>  > >  > two comments:
>  > >  > 
>  > >  > 1) should use pci_iomap() for both PIO and MMIO
>  > >  > 
>  > >  > 2) modparam should be "use_io" mirroring existing drivers
>  > > 
>  > > Ok, I'll take a stab at those later today (and also your comment
>  > > from the other mail).
>  > > 
>  > > One other thing: I wasn't sure about my changes to rtl8139_get_regs
>  > > and rtl8139_get_regs_len.  Is what I did there safe?
>  > > Obviously actually implementing support for PIO reg dumping would
>  > > be better, but I think that's beyond the scope of what I'm trying
>  > > to do for now.
>  > 
>  > Yeah, that should be reasonable
> 
> Finally got back to this.  How does this look?
> 
> 	Dave
> 
> 
> 
> Make PIO/MMIO a runtime thing via a module parameter.
> This is needed to support devices that only work with PIO
> without penalising devices that work fine with MMIO in
> distro kernels.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Looks great overall.

Minor nits:

* need module param text description

* [optional] if code not too ugly, change mod param description based on 
CONFIG_8139TOO_PIO to indicate the currently compiled default

* [optional] would prefer CONFIG_8139TOO_PIO be handled at compile time, 
by changing the initialized value

* [extra project] would be highly useful for MMIO to fall back to PIO, 
and vice versa, should any resource be unavailable.  Sometimes, mainly 
with MMIO and broken/weird BIOSen, only the PIO PCI BARs will be filled 
in with useful info.

