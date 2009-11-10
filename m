From: leitao@linux.vnet.ibm.com
Subject: [PATCH] s2io: fixing a ethtool test that is broken
Date: Tue, 10 Nov 2009 14:44:23 -0500
Message-ID: <1257882263-7507-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: sreenivasa.honnur@neterion.com,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:40793 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757916AbZKJTqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 14:46:39 -0500
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp03.br.ibm.com (8.14.3/8.13.1) with ESMTP id nAAIevML032323
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 16:40:57 -0200
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAAJlkBQ934146
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 17:47:47 -0200
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAAJkfl1013117
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 17:46:41 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due commit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff, it is not more
possible to pci_restore_state() more than once without calling
pci_save_state() in the middle.

Actually running a ethtool test on s2io makes the card inactive, 
and it needs to unload/reload the module to fix. 

This patch just save the state just after it restore in order to
keep the old behaviour

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/s2io.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index ddccf5f..0dd7839 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3494,6 +3494,7 @@ static void s2io_reset(struct s2io_nic *sp)
 
 		/* Restore the PCI state saved during initialization. */
 		pci_restore_state(sp->pdev);
+		pci_save_state(sp->pdev);
 		pci_read_config_word(sp->pdev, 0x2, &val16);
 		if (check_pci_device_id(val16) != (u16)PCI_ANY_ID)
 			break;
-- 
1.6.0.2

