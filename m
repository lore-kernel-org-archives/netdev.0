From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: [PATCH] mwifiex: remove unnecessary call to memset
Date: Mon, 11 Sep 2017 18:16:04 +0530
Message-ID: <1505133964-376-1-git-send-email-himanshujha199640@gmail.com>
Cc: nishants@marvell.com, gbhat@marvell.com, huxm@marvell.com,
        kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Himanshu Jha <himanshujha199640@gmail.com>
To: amitkarwar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36177 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbdIKMqV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 08:46:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

call to memset to assign 0 value immediately after allocating
memory with kzalloc is unnecesaary as kzalloc allocates the memory
filled with 0 value.

Semantic patch used to resolve this issue:

@@
expression e,e2; constant c;
statement S;
@@

  e = kzalloc(e2, c);
  if(e == NULL) S
- memset(e, 0, e2);

Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>
---
 drivers/net/wireless/marvell/mwifiex/scan.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/scan.c b/drivers/net/wireless/marvell/mwifiex/scan.c
index c9d41ed..8838b88 100644
--- a/drivers/net/wireless/marvell/mwifiex/scan.c
+++ b/drivers/net/wireless/marvell/mwifiex/scan.c
@@ -1936,8 +1936,6 @@ mwifiex_active_scan_req_for_passive_chan(struct mwifiex_private *priv)
 	if (!user_scan_cfg)
 		return -ENOMEM;
 
-	memset(user_scan_cfg, 0, sizeof(*user_scan_cfg));
-
 	for (id = 0; id < MWIFIEX_USER_SCAN_CHAN_MAX; id++) {
 		if (!priv->hidden_chan[id].chan_number)
 			break;
-- 
2.7.4
