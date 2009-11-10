From: leitao@linux.vnet.ibm.com
Subject: [PATCH] ixgbe: Fixing EEH handler to handle more than one error
Date: Tue, 10 Nov 2009 13:37:47 -0500
Message-ID: <1257878267-7489-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: peter.p.waskiewicz.jr@intel.com, jeffrey.t.kirsher@intel.com,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:55950 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757584AbZKJSkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:40:40 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp03.br.ibm.com (8.14.3/8.13.1) with ESMTP id nAAHYuvA001189
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 15:34:56 -0200
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAAIefll3567854
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 15:40:41 -0300
Received: from d24av03.br.ibm.com (d24av03 [127.0.0.1])
	by d24av03.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAAIefIM006553
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 16:40:41 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commmit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff EEH breaks
after the second error, since it calls pci_restore_state()
but it returns 0, since pci->state_saved is false.

So, this patch just call pci_save_state() after pci_restore_state().

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5bd9e6b..a5036f7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5994,6 +5994,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 	} else {
 		pci_set_master(pdev);
 		pci_restore_state(pdev);
+		pci_save_state(pdev);
 
 		pci_wake_from_d3(pdev, false);
 
-- 
1.6.0.2

