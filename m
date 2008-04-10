From: wendy xiong <wendyx@us.ibm.com>
Subject: [PATCH 1/2 2.6.25-rc8] e1000e: save and restore pcie/msi state to
	support EEH recovery
Date: Thu, 10 Apr 2008 14:39:50 -0500
Message-ID: <1207856390.24768.26.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:33271 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750975AbYDJTjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 15:39:54 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3AJdqYE016382
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 15:39:52 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3AJdqRa388154
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 15:39:52 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3AJdpl7002611
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 15:39:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

To enable EEH support for pci-express network adapters, pcie/msi state
needs to be saved and restored for that adapter.

We have tested this EEH patch with 2ports and 4ports pci-express e1000e
adapters.

Signed-off-by: Wendy Xiong <wendyx@us.ibm.com>


diff -Nuarp linux-2.6.25-rc8.orig/drivers/net/e1000e/netdev.c linux-2.6.25-rc8/drivers/net/e1000e/netdev.c
--- linux-2.6.25-rc8.orig/drivers/net/e1000e/netdev.c   2008-04-07 19:18:08.000000000 -0500
+++ linux-2.6.25-rc8/drivers/net/e1000e/netdev.c        2008-04-10 13:13:21.000000000 -0500
@@ -3630,6 +3630,7 @@ static pci_ers_result_t e1000_io_slot_re
                return PCI_ERS_RESULT_DISCONNECT;
        }
        pci_set_master(pdev);
+       pci_restore_state(pdev);

        pci_enable_wake(pdev, PCI_D3hot, 0);
        pci_enable_wake(pdev, PCI_D3cold, 0);
@@ -3754,6 +3755,7 @@ static int __devinit e1000_probe(struct
                goto err_pci_reg;

        pci_set_master(pdev);
+       pci_save_state(pdev);

        err = -ENOMEM;
        netdev = alloc_etherdev(sizeof(struct e1000_adapter));


