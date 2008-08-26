From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 5/5] igb: fix setting the number of tx queues
Date: Tue, 26 Aug 2008 04:25:13 -0700
Message-ID: <20080826112513.15627.24776.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37230 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281AbYHZLZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:25:13 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099147rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:25:13 -0700 (PDT)
In-Reply-To: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The real_num_tx_queues was not being set when in MSI-X only mode.  This patch
corrects that path so all interrupt types are correctly configured.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 2728730..93d02ef 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -520,7 +520,7 @@ static void igb_set_interrupt_capability(struct igb_adapter *adapter)
 			      adapter->msix_entries,
 			      numvecs);
 	if (err == 0)
-		return;
+		goto out;
 
 	igb_reset_interrupt_capability(adapter);
 
@@ -530,7 +530,7 @@ msi_only:
 	adapter->num_tx_queues = 1;
 	if (!pci_enable_msi(adapter->pdev))
 		adapter->flags |= IGB_FLAG_HAS_MSI;
-
+out:
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
 	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
 	return;

