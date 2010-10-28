From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgb: call pci_disable_device in ixgb_remove
Date: Thu, 28 Oct 2010 03:59:49 -0700
Message-ID: <20101028105949.27748.82780.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:54684
	"EHLO qmta15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756549Ab0J1K7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 06:59:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

ixgb fails to work after reload on recent kernels:

rmmod ixgb (dev->current_state = PCI_UNKNOWN)
modprobe ixgb (pci_enable_device will bail leaving current_state to PCI_UNKNOWN)
ifup eth0
do_IRQ: 2.82 No irq handler for vector (irq -1)

The issue was exposed by commit fcd097f31a6ee207cc0c3da9cccd2a86d4334785
PCI: MSI: Remove unsafe and unnecessary hardware access

which avoids HW writes for power states != PCI_D0

CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 666207a..caa8192 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -533,6 +533,7 @@ ixgb_remove(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 
 	free_netdev(netdev);
+	pci_disable_device(pdev);
 }
 
 /**

