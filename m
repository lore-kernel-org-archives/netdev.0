From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sun, 30 May 2010 19:30:15 +0200
Message-ID: <20100530173014.GB14556@basil.fritz.box>
References: <1275103462-8527-1-git-send-email-mchan@broadcom.com> <87ocfxzpvf.fsf@basil.nowhere.org> <C27F8246C663564A84BB7AB3439772421B78147574@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Andi Kleen' <andi@firstfloor.org>,
	"'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-pci@vger.kernel.org'" <linux-pci@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B78147574@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 30, 2010 at 09:12:15AM -0700, Michael Chan wrote:
> Andi Kleen wrote:
> 
> > "Michael Chan" <mchan@broadcom.com> writes:
> > 
> > > When switching from the crashed kernel to the kdump kernel without
> > going
> > > through PCI reset, IRQs may not work if a different IRQ mode is used
> > on
> > 
> > PCIe with AER actually does support per link root port reset
> > (e.g. used for AER)
> 
> Do you mean the slot_reset function in the pci_error_handlers?  This

Well the fallback code in the PCIE root port driver 
that does the actual resets.

It could be called directly before kexec.

> needs to be called in the context of the crashed kernel, right?

It could be done on kexec, however of course you would rely
on PCI root port data structures still being intact on a crash
(I guess that's reasonable, they are not very complicated)

> 
> > 
> > I've been wondering for some time if kexec should not simply
> > use that to reset all the devices, instead of addings hacks
> > around this to all drivers.
> > 
> > That would fix your problems too, right?
> 
> If it is called in the context of the crashed kernel, it won't work.
> We would reset it and put in back into the same IRQ mode.

Who would put it back? Your driver wouldn't be called anymore.

> 
> > 
> > The question is just if AER is widely enough supported for this.
> > 
> 
> Some newer PCIe devices support Function Level Reset, and that would
> be ideal.  But most existing devices including bnx2 devices don't have
> this feature.

Root port reset should be fine for this case. Even if some
innocent device on the same root port gets reset too that shouldn't matter. 
Only drawback for the NIC would be that you have to renegotiate links I think. 

Also there are systems without AER support.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
