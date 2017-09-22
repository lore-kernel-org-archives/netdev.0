From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 1/5] net: nfc: hci: use setup_timer() helper.
Date: Fri, 22 Sep 2017 16:28:18 +0530
Message-ID: <1506077902-1796-2-git-send-email-allen.lkml@gmail.com>
References: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Cc: davem@davemloft.net, sameo@linux.intel.com,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34843 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751903AbdIVK6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 06:58:33 -0400
Received: by mail-pg0-f65.google.com with SMTP id j16so441010pga.2
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 03:58:33 -0700 (PDT)
In-Reply-To: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Use setup_timer function instead of initializing timer with the
   function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 net/nfc/hci/core.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/nfc/hci/core.c b/net/nfc/hci/core.c
index b740fef..a8a6e78 100644
--- a/net/nfc/hci/core.c
+++ b/net/nfc/hci/core.c
@@ -1004,9 +1004,8 @@ int nfc_hci_register_device(struct nfc_hci_dev *hdev)
 
 	INIT_WORK(&hdev->msg_tx_work, nfc_hci_msg_tx_work);
 
-	init_timer(&hdev->cmd_timer);
-	hdev->cmd_timer.data = (unsigned long)hdev;
-	hdev->cmd_timer.function = nfc_hci_cmd_timeout;
+	setup_timer(&hdev->cmd_timer, nfc_hci_cmd_timeout,
+		    (unsigned long)hdev);
 
 	skb_queue_head_init(&hdev->rx_hcp_frags);
 
-- 
2.7.4
