From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] caif: Remove redundant null check before kfree in cfctrl.c
Date: Tue, 20 Nov 2012 16:23:58 +0530
Message-ID: <1353408838-28678-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sjur.brandeland@stericsson.com,
	sachin.kamat@linaro.org, patches@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:47930 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855Ab2KTLAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 06:00:08 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so4199224pbc.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 03:00:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree on a null pointer is a no-op.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 net/caif/cfctrl.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 44f270f..a376ec1 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -515,8 +515,7 @@ static int cfctrl_recv(struct cflayer *layer, struct cfpkt *pkt)
 							  client_layer : NULL);
 			}
 
-			if (req != NULL)
-				kfree(req);
+			kfree(req);
 
 			spin_unlock_bh(&cfctrl->info_list_lock);
 		}
-- 
1.7.4.1
