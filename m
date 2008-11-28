From: Thomas Renninger <trenn@suse.de>
Subject: PCIe ASPM causes machine (HP Compaq 6735s) to sometimes freeze hard at boot at PCI initialization time
Date: Fri, 28 Nov 2008 13:28:54 +0100
Message-ID: <200811281328.55259.trenn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jbarnes@virtuousgeek.org, shaohua.li@intel.com,
	Rafael Wysocki <rwysocki@suse.de>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:43590 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbYK1M27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2008 07:28:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The hang does not always happen.
On latest vanilla 2.6.28-rc6 it nearly always hangs, on a .27 SUSE kernel 
maybe 1 out for 3 times.

I very much expect (I am pretty sure now) it is PCIE ASPM.

I tried to compile out:
CONFIG_PCIEAER=y
CONFIG_PCIEASPM=y

Both disabled survived a reasonable amount of reboots, but when enabling 
CONFIG_PCIEASPM it did not boot anymore on the second try.

The machine is hanging at the network card's PCI initialization rather early, 
here is a photo of the hang:
ftp.suse.com/pub/people/trenn/HP_pci_aspm_hang.jpg

This is the network card:
Marvell 11ab:4357 (PCI ID) using the sky2 driver.
Once the machine booted (even with aspm enabled, the network device works
properly).

Possibly unrelated, because the machine hangs far before the sky2 driver kicks
in or does PCI subsystem already need to set something similar?:

The sky2 driver has some extra ASPM poking in its power_on routine:
/* set all bits to 0 except bits 15..12 and 8 */
                reg &= P_ASPM_CONTROL_MSK;
                sky2_pci_write32(hw, PCI_DEV_REG4, reg);


It seem to be this Marval/Yukon card:
CHIP_ID_YUKON_UL_2 = 0xba, /* YUKON-2 Ultra 2 */

Oh wait,
The SubDevice PCI ID (via hwinfo --netcard) is 0xba, but the driver thinks it
is a (via dmesg):
CHIP_ID_YUKON_FE_P = 0xb8, /* YUKON-2 FE+ */

Any ideas from people with more knowledge in the PCI(e) area is very much 
appreciated.

Thanks,

      Thomas
