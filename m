From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: pcie_get_minimum_link returns 0 width
Date: Mon, 26 Aug 2013 18:27:29 +0000
Message-ID: <02874ECE860811409154E81DA85FBB58565A7F3B@ORSMSX104.amr.corp.intel.com>
References: <20130825100157.GA16500@lb-tlvb-yuvalmin.il.broadcom.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AD136BE@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A52AD136BE@SJEXCHMB10.corp.ad.broadcom.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Yuval Mintz [mailto:yuvalmin@broadcom.com]
> Sent: Sunday, August 25, 2013 4:22 AM
> To: Keller, Jacob E
> Cc: bhelgaas@google.com; linux-pci@vger.kernel.org;
> netdev@vger.kernel.org
> Subject: pcie_get_minimum_link returns 0 width
> 
> Hi,
> 
> I tried adding support for the newly added 'pcie_get_minimum_link' into
> the
> bnx2x driver, but found out the some of my devices started showing
> width x0.
> 
> By adding debug prints, I've found out there were devices up the chain
> that
> Showed 0 when their PCI_EXP_LNKSTA was read by said function.
> However, when I tried looking via lspci the output claimed the width was
> x4.
> 
> lspci -vt output:
> [0000:00]-+-00.0  Intel Corporation 5000P Chipset Memory Controller
> Hub
> 	     +-02.0-[09-12]--+-00.0-[0a-11]--+-00.0-[0b-0d]--
> 					     +-01.0-[0e-10]--+-00.0
> Broadcom
> 					Corporation NetXtreme II
> BCM57710
> 					10-Gigabit PCIe [Everest]
> 
> Where:
> 00:02.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express x4
> Port
> 2 (rev 93)
> 09:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
> Upstream
> Port (rev 01)
> 0a:01.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
> Downstream Port E2 (rev 01)
> 0e:00.0 Ethernet controller: Broadcom Corporation NetXtreme II
> BCM57710
> 10-Gigabit PCIe [Everest] (rev 01)
> 
> The output for "lspci -vvvv | grep LnkSta for all four is:
> LnkSta:	Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive-
> BWMgmt-
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

Interesting... It looks like the entire LnkSta  read failed for the two in the middle..  I don't know how much I can help on this issue because I don't have a machine that exhibits this symptom.. Any suggestions?

Regards,
Jake
