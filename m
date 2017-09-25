From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH v2 4/4] net: nfc: llcp_core: use setup_timer() helper.
Date: Mon, 25 Sep 2017 13:00:05 +0530
Message-ID: <1506324605-10160-4-git-send-email-allen.lkml@gmail.com>
References: <1506324605-10160-1-git-send-email-allen.lkml@gmail.com>
Cc: davem@davemloft.net, sameo@linux.intel.com,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34531 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933668AbdIYHcC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 03:32:02 -0400
Received: by mail-pf0-f194.google.com with SMTP id g65so3291318pfe.1
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 00:32:02 -0700 (PDT)
In-Reply-To: <1506324605-10160-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use setup_timer function instead of initializing timer with the
   function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
v2: rebased to latest net-next.

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
