From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: pcie_get_minimum_link returns 0 width
Date: Mon, 26 Aug 2013 16:05:18 -0600
Message-ID: <CAErSpo4NmL0RWcBompuweHNYmhNmLXU_21_gvaqfDEzi+HBp5g@mail.gmail.com>
References: <20130825100157.GA16500@lb-tlvb-yuvalmin.il.broadcom.com> <979A8436335E3744ADCD3A9F2A2B68A52AD136BE@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "jacob.e.keller@intel.com" <jacob.e.keller@intel.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AD136BE@SJEXCHMB10.corp.ad.broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 25, 2013 at 5:21 AM, Yuval Mintz <yuvalmin@broadcom.com> wrote:
> Hi,
>
> I tried adding support for the newly added 'pcie_get_minimum_link' into the
> bnx2x driver, but found out the some of my devices started showing width x0.
>
> By adding debug prints, I've found out there were devices up the chain that
> Showed 0 when their PCI_EXP_LNKSTA was read by said function.
> However, when I tried looking via lspci the output claimed the width was x4.

I don't see a 'pcie_get_minimum_link()' function in my current tree
(git://git.kernel.org/pub/scm/linux/kernel/git/helgaas/pci.git "next"
branch).  Maybe seeing your patch (with the debug prints) would give
me a hook for somewhere to start looking.

Can you figure out why lspci shows the correct value and this kernel
interface does not?  The current lspci source is in
git://git.kernel.org/pub/scm/utils/pciutils/pciutils.git and the
relevant code is probably in cap_express_link() here:
http://git.kernel.org/cgit/utils/pciutils/pciutils.git/tree/ls-caps.c#n750

> lspci -vt output:
> [0000:00]-+-00.0  Intel Corporation 5000P Chipset Memory Controller Hub
>              +-02.0-[09-12]--+-00.0-[0a-11]--+-00.0-[0b-0d]--
>                                              +-01.0-[0e-10]--+-00.0  Broadcom
>                                         Corporation NetXtreme II BCM57710
>                                         10-Gigabit PCIe [Everest]
>
> Where:
> 00:02.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x4 Port
> 2 (rev 93)
> 09:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Upstream
> Port (rev 01)
> 0a:01.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
> Downstream Port E2 (rev 01)
> 0e:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM57710
> 10-Gigabit PCIe [Everest] (rev 01)
>
> The output for "lspci -vvvv | grep LnkSta for all four is:
> LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt-
> ABWMgmt-
>
> But added prints inside the function's loop show:
> LnkSta 1041 [000e:00.00]
> LnkSta 0000 [000a:01.00]
> LnkSta 0000 [0009:00.00]
> LnkSta 3041 [0000:02.00]
> (PCI_EXP_LNKSTA value, bus->number, PCI_SLOT, PCI_FUNC)
>
> Thanks,
> Yuval
>
