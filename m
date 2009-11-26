From: leitao@linux.vnet.ibm.com
Subject: [PATCH] bnx2: EEH is failing with timeout
Date: Thu, 26 Nov 2009 11:31:49 -0600
Message-ID: <1259256709-6976-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:40218 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbZKZRcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 12:32:23 -0500
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.3/8.13.1) with ESMTP id nAQHruNQ029102
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2009 15:53:56 -0200
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAQHXo9g1032394
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2009 15:33:50 -0200
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAQHWRjF000797
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2009 15:32:28 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2 is failing when a PCI error is detected. The error is the
following:

bnx2: Chip not in correct endian mode
bnx2: fw sync timeout, reset code = 404001d

This error was caused because the way pci_restore_state() is working
after commit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff.

Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>
---
 drivers/net/bnx2.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 08cddb6..7fa4048 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -8264,6 +8264,7 @@ static pci_ers_result_t bnx2_io_slot_reset(struct pci_dev *pdev)
 	}
 	pci_set_master(pdev);
 	pci_restore_state(pdev);
+	pci_save_state(pdev);
 
 	if (netif_running(dev)) {
 		bnx2_set_power_state(bp, PCI_D0);
-- 
1.6.0.2

