From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/4] e1000: remove PCI Express device IDs
Date: Mon, 19 May 2008 15:46:47 -0700
Message-ID: <20080519224516.7175.57123.stgit@localhost.localdomain>
References: <20080519224303.7175.71980.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25468 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753348AbYESWqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 18:46:48 -0400
In-Reply-To: <20080519224303.7175.71980.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We do not want to prolong the situation much longer that e1000
and e1000e support these devices at the same time. As a result,
take out the bandage that was added for the interim period
and remove all the PCI Express device IDs from e1000.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Garzik <jeff@garzik.org>
---

 drivers/net/Kconfig            |    3 ---
 drivers/net/e1000/e1000_main.c |   33 ---------------------------------
 2 files changed, 0 insertions(+), 36 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index af46341..fb648bd 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2028,9 +2028,6 @@ config E1000E
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000e.
 
-config E1000E_ENABLED
-	def_bool E1000E != n
-
 config IP1000
 	tristate "IP1000 Gigabit Ethernet support"
 	depends on PCI && EXPERIMENTAL
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 59579b1..b0e2493 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -47,12 +47,6 @@ static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation
  * Macro expands to...
  *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
  */
-#ifdef CONFIG_E1000E_ENABLED
-  #define PCIE(x) 
-#else
-  #define PCIE(x) x,
-#endif
-
 static struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x1000),
 	INTEL_E1000_ETHERNET_DEVICE(0x1001),
@@ -79,14 +73,6 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x1026),
 	INTEL_E1000_ETHERNET_DEVICE(0x1027),
 	INTEL_E1000_ETHERNET_DEVICE(0x1028),
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1049))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104A))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104B))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104C))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x104D))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x105E))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x105F))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1060))
 	INTEL_E1000_ETHERNET_DEVICE(0x1075),
 	INTEL_E1000_ETHERNET_DEVICE(0x1076),
 	INTEL_E1000_ETHERNET_DEVICE(0x1077),
@@ -95,28 +81,9 @@ PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1060))
 	INTEL_E1000_ETHERNET_DEVICE(0x107A),
 	INTEL_E1000_ETHERNET_DEVICE(0x107B),
 	INTEL_E1000_ETHERNET_DEVICE(0x107C),
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x107D))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x107E))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x107F))
 	INTEL_E1000_ETHERNET_DEVICE(0x108A),
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x108B))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x108C))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1096))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x1098))
 	INTEL_E1000_ETHERNET_DEVICE(0x1099),
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x109A))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10A4))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10A5))
 	INTEL_E1000_ETHERNET_DEVICE(0x10B5),
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10B9))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10BA))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10BB))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10BC))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10C4))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10C5))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10D5))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10D9))
-PCIE(	INTEL_E1000_ETHERNET_DEVICE(0x10DA))
 	/* required last entry */
 	{0,}
 };

