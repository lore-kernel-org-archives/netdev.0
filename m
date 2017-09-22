From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 4/5] net: nfc: core: use setup_timer() helper.
Date: Fri, 22 Sep 2017 16:28:21 +0530
Message-ID: <1506077902-1796-5-git-send-email-allen.lkml@gmail.com>
References: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Cc: davem@davemloft.net, sameo@linux.intel.com,
        Allen Pais <allen.lkml@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38750 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752062AbdIVK6l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 06:58:41 -0400
Received: by mail-pf0-f194.google.com with SMTP id a7so316294pfj.5
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 03:58:41 -0700 (PDT)
In-Reply-To: <1506077902-1796-1-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Use setup_timer function instead of initializing timer with the
   function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 net/nfc/core.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/nfc/core.c b/net/nfc/core.c
index 5cf33df..e5e23c2 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -1094,9 +1094,8 @@ struct nfc_dev *nfc_allocate_device(struct nfc_ops *ops,
 	dev->targets_generation = 1;
 
 	if (ops->check_presence) {
-		init_timer(&dev->check_pres_timer);
-		dev->check_pres_timer.data = (unsigned long)dev;
-		dev->check_pres_timer.function = nfc_check_pres_timeout;
+		setup_timer(&dev->check_pres_timer, nfc_check_pres_timeout,
+			    (unsigned long)dev);
 
 		INIT_WORK(&dev->check_pres_work, nfc_check_pres_work);
 	}
-- 
2.7.4
