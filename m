From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Drop ISA dependencies from IRDA drivers
Date: Fri, 16 Jul 2004 08:19:13 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040716061913.GB662@wotan.suse.de>
References: <20040716054550.GA21819@muc.de> <Pine.LNX.4.44.0407160801190.14037-100000@notebook.home.mdiehl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@oss.sgi.com, irda-users@lists.sourceforge.net,
	Jean Tourrilhes <jt@hpl.hp.com>, the_nihilant@autistici.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266489AbUGPGTR@vger.kernel.org>
To: Martin Diehl <lists@mdiehl.de>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0407160801190.14037-100000@notebook.home.mdiehl.de>
List-Id: netdev.vger.kernel.org

On Fri, Jul 16, 2004 at 08:19:04AM +0200, Martin Diehl wrote:
> On 16 Jul 2004, Andi Kleen wrote:
> 
> > > Admittedly I haven't tried either, but I'm pretty sure this patch will 
> > > break building those drivers because they are calling irda_setup_dma - 
> > > which is CONFIG_ISA. Maybe this can be dropped but I don't see what's 
> > > wrong with !64BIT instead.
> > 
> > Hmm, good point. 
> > 
> > !64BIT is not needed - apparently they are 64bit clean.
> 
> I think you are right - however, AFAICS this is not the point in this 
> case. These drivers do DMA to legacy devices (call it ISA, LPC, whatever). 
> The documented way for those devices without struct pci_dev is to call the 
> dma api functions with dev=NULL. For i386 the generic dma functions are 
> overwritten so they use GFP_DMA f.e. in this case.


There was at least one user report that at least one driver worked 
with CONFIG_ISA force defined.

> 
> According to include/asm-x86_64/dma-mapping.h there is no such override 
> for x86-64. Hence the generic implementation is used which Oopses when 
> called with dev=NULL in dma_alloc_coherent because it dereferences dev 
> unconditionally.

The old pci_alloc_coherent supported hwdev == NULL under x86-64.
dma_alloc_consistent() should too. I will fix that. 

-Andi
