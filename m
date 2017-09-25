From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH v2 2/4] net: nfc: hci: use setup_timer() helper.
Date: Mon, 25 Sep 2017 13:00:03 +0530
Message-ID: <1506324605-10160-2-git-send-email-allen.lkml@gmail.com>
References: <1506324605-10160-1-git-send-email-allen.lkml@gmail.com>
Cc: davem@davemloft.net, sameo@linux.intel.com,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33050 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932135AbdIYHb5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 03:31:57 -0400
Received: by mail-pf0-f193.google.com with SMTP id h4so3290627pfk.0
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 00:31:57 -0700 (PDT)
In-Reply-To: <1506324605-10160-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use setup_timer function instead of initializing timer with the
   function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
v2: rebased to latest net-next.

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
