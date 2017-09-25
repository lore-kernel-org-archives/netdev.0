From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH v2 3/4] net: nfc: hci: llc_shdlc: use setup_timer() helper.
Date: Mon, 25 Sep 2017 13:00:04 +0530
Message-ID: <1506324605-10160-3-git-send-email-allen.lkml@gmail.com>
References: <1506324605-10160-1-git-send-email-allen.lkml@gmail.com>
Cc: davem@davemloft.net, sameo@linux.intel.com,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33058 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933656AbdIYHcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 03:32:00 -0400
Received: by mail-pf0-f195.google.com with SMTP id h4so3290671pfk.0
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 00:32:00 -0700 (PDT)
In-Reply-To: <1506324605-10160-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use setup_timer function instead of initializing timer with the
   function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
v2: rebased to latest net-next.

 net/nfc/hci/llc_shdlc.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/nfc/hci/llc_shdlc.c b/net/nfc/hci/llc_shdlc.c
index 17e59a0..58df37e 100644
--- a/net/nfc/hci/llc_shdlc.c
+++ b/net/nfc/hci/llc_shdlc.c
@@ -763,17 +763,14 @@ static void *llc_shdlc_init(struct nfc_hci_dev *hdev, xmit_to_drv_t xmit_to_drv,
 	mutex_init(&shdlc->state_mutex);
 	shdlc->state = SHDLC_DISCONNECTED;
 
-	init_timer(&shdlc->connect_timer);
-	shdlc->connect_timer.data = (unsigned long)shdlc;
-	shdlc->connect_timer.function = llc_shdlc_connect_timeout;
+	setup_timer(&shdlc->connect_timer, llc_shdlc_connect_timeout,
+		    (unsigned long)shdlc);
 
-	init_timer(&shdlc->t1_timer);
-	shdlc->t1_timer.data = (unsigned long)shdlc;
-	shdlc->t1_timer.function = llc_shdlc_t1_timeout;
+	setup_timer(&shdlc->t1_timer, llc_shdlc_t1_timeout,
+		    (unsigned long)shdlc);
 
-	init_timer(&shdlc->t2_timer);
-	shdlc->t2_timer.data = (unsigned long)shdlc;
-	shdlc->t2_timer.function = llc_shdlc_t2_timeout;
+	setup_timer(&shdlc->t2_timer, llc_shdlc_t2_timeout,
+		    (unsigned long)shdlc);
 
 	shdlc->w = SHDLC_MAX_WINDOW;
 	shdlc->srej_support = SHDLC_SREJ_SUPPORT;
-- 
2.7.4
