From: wendy xiong <wendyx@us.ibm.com>
Subject: [PATCH 2/2 2.6.25-rc8] ixgbe: save and restore pcie/msi state to
	support EEH recovery
Date: Thu, 10 Apr 2008 14:40:34 -0500
Message-ID: <1207856434.24768.27.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:48580 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755922AbYDJTkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 15:40:36 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3AJgeaH026477
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 15:42:40 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3AJeZMF293386
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 15:40:35 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3AJeZeh005659
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 15:40:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

To enable EEH support for pci-express network adapters, pcie/msi state
needs to be saved and restored for that adapter.

We have tested this EEH patch with Intel 10G pci-express ixgbe adapter.

Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>


diff -Nuarp linux-2.6.25-rc8.orig/drivers/net/ixgbe/ixgbe_main.c linux-2.6.25-rc8/drivers/net/ixgbe/ixgbe_main.c
--- linux-2.6.25-rc8.orig/drivers/net/ixgbe/ixgbe_main.c        2008-04-07 19:18:08.000000000 -0500
+++ linux-2.6.25-rc8/drivers/net/ixgbe/ixgbe_main.c     2008-04-10 12:54:17.000000000 -0500
@@ -2654,6 +2654,7 @@ static int __devinit ixgbe_probe(struct
        }

        pci_set_master(pdev);
+       pci_save_state(pdev);

        netdev = alloc_etherdev(sizeof(struct ixgbe_adapter));
        if (!netdev) {
@@ -2910,6 +2911,7 @@ static pci_ers_result_t ixgbe_io_slot_re
                return PCI_ERS_RESULT_DISCONNECT;
        }
        pci_set_master(pdev);
+       pci_restore_state(pdev);

        pci_enable_wake(pdev, PCI_D3hot, 0);
        pci_enable_wake(pdev, PCI_D3cold, 0);




