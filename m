From: Tony Prisk <linux@prisktech.co.nz>
Subject: [PATCHv5 0/3] Add support for velocity network driver on platform devices
Date: Fri,  3 May 2013 06:46:02 +1200
Message-ID: <1367520365-18842-1-git-send-email-linux@prisktech.co.nz>
Cc: romieu@fr.zoreil.com, vt8500-wm8505-linux-kernel@googlegroups.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk,
	Tony Prisk <linux@prisktech.co.nz>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v5 changes:
Remove velocity_info union. Change velocity_info->pdev back to struct pci_dev.
Remove more 'if (pci)' sections.
Remove 'void *pdev' function parameters.
Pass correct variable to velocity_choose_state()

v4 changes:
Code tidyup as requested by Francois Romieu
Removed '#ifdef PCI' around PCI code. Compile tested on (!)PCI and (!)PM.

v3 changes:
Rebased against net-next.
Fix errors in pm code.

v2 changes:
Drop patch #1 as requested by David Miller.
Correct the PHYID_ICPLUS_IP101A MII bits - should be ON, rather than OFF.
Read the platform rev_id from the correct register [regs->rev_id]. It's possible
this would work for the PCI version as well and would remove the need for the
'if (pci)' test to set vptr->rev_id.

v1:
The first three patches are general tidyup.

[DROPPED] Patch ## just alphabetizes the #includes to make it easier to read.

Patch #1 replaces vptr->dev with vptr->netdev, in preparation of adding a
struct device *dev in Patch #3

Patch #2 replaces the pci dma functions with the generic versions.

I have build tested these patches but don't have a PCI velocity to run-test it.
I can't see that they should introduce any problems as it is all renames and
function swapping.

Patch #3 adds support for the velocity driver on devicetree platform devices.
Binding document included. This patch is compile-tested for PCI, and boot
tested on a VIA APC8750.

I think it would be pertinent to get some tested-by's for PCI users.

Regards
Tony Prisk

Tony Prisk (3):
  net: velocity: Rename vptr->dev to vptr->netdev
  net: velocity: Convert to generic dma functions
  net: velocity: Add platform device support to VIA velocity driver

 .../devicetree/bindings/net/via-velocity.txt       |   20 +
 drivers/net/ethernet/via/Kconfig                   |    3 +-
 drivers/net/ethernet/via/via-velocity.c            |  543 +++++++++++++-------
 drivers/net/ethernet/via/via-velocity.h            |   35 +-
 4 files changed, 419 insertions(+), 182 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/via-velocity.txt

-- 
1.7.9.5
