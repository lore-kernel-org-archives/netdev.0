From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: Fix IRQ failures during kdump.
Date: Sun, 30 May 2010 09:12:15 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B78147574@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1275103462-8527-1-git-send-email-mchan@broadcom.com>
 <87ocfxzpvf.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-pci@vger.kernel.org'" <linux-pci@vger.kernel.org>
To: "'Andi Kleen'" <andi@firstfloor.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <87ocfxzpvf.fsf@basil.nowhere.org>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> "Michael Chan" <mchan@broadcom.com> writes:
> 
> > When switching from the crashed kernel to the kdump kernel without
> going
> > through PCI reset, IRQs may not work if a different IRQ mode is used
> on
> 
> PCIe with AER actually does support per link root port reset
> (e.g. used for AER)

Do you mean the slot_reset function in the pci_error_handlers?  This
needs to be called in the context of the crashed kernel, right?

> 
> I've been wondering for some time if kexec should not simply
> use that to reset all the devices, instead of addings hacks
> around this to all drivers.
> 
> That would fix your problems too, right?

If it is called in the context of the crashed kernel, it won't work.
We would reset it and put in back into the same IRQ mode.

> 
> The question is just if AER is widely enough supported for this.
> 

Some newer PCIe devices support Function Level Reset, and that would
be ideal.  But most existing devices including bnx2 devices don't have
this feature.
