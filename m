From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 5/5] net: nfc: llcp_core: use setup_timer() helper.
Date: Fri, 22 Sep 2017 16:28:22 +0530
Message-ID: <1506077902-1796-6-git-send-email-allen.lkml@gmail.com>
References: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Cc: davem@davemloft.net, sameo@linux.intel.com,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33724 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752072AbdIVK6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 06:58:44 -0400
Received: by mail-pg0-f65.google.com with SMTP id i130so447865pgc.0
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 03:58:44 -0700 (PDT)
In-Reply-To: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Use setup_timer function instead of initializing timer with the
   function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 net/nfc/llcp_core.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/nfc/llcp_core.c b/net/nfc/llcp_core.c
index 02eef5c..7988185 100644
--- a/net/nfc/llcp_core.c
+++ b/net/nfc/llcp_core.c
@@ -1573,9 +1573,8 @@ int nfc_llcp_register_device(struct nfc_dev *ndev)
 	INIT_LIST_HEAD(&local->list);
 	kref_init(&local->ref);
 	mutex_init(&local->sdp_lock);
-	init_timer(&local->link_timer);
-	local->link_timer.data = (unsigned long) local;
-	local->link_timer.function = nfc_llcp_symm_timer;
+	setup_timer(&local->link_timer, nfc_llcp_symm_timer,
+		    (unsigned long)local);
 
 	skb_queue_head_init(&local->tx_queue);
 	INIT_WORK(&local->tx_work, nfc_llcp_tx_work);
@@ -1601,9 +1600,8 @@ int nfc_llcp_register_device(struct nfc_dev *ndev)
 
 	mutex_init(&local->sdreq_lock);
 	INIT_HLIST_HEAD(&local->pending_sdreqs);
-	init_timer(&local->sdreq_timer);
-	local->sdreq_timer.data = (unsigned long) local;
-	local->sdreq_timer.function = nfc_llcp_sdreq_timer;
+	setup_timer(&local->sdreq_timer, nfc_llcp_sdreq_timer,
+		    (unsigned long)local);
 	INIT_WORK(&local->sdreq_timeout_work, nfc_llcp_sdreq_timeout_work);
 
 	list_add(&local->list, &llcp_devices);
-- 
2.7.4
