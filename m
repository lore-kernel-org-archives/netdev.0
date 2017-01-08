From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 1/4] net: ethernet: ti: cpsw: remove dual check from common res usage function
Date: Sun,  8 Jan 2017 18:41:00 +0200
Message-ID: <1483893663-15673-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33759 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753863AbdAHQlJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 11:41:09 -0500
Received: by mail-lf0-f42.google.com with SMTP id k86so81784150lfi.0
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 08:41:09 -0800 (PST)
In-Reply-To: <1483893663-15673-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Common res usage is possible only in case an interface is
running. In case of not dual emac here can be only one interface,
so while ndo_open and switch mode, only one interface can be opened,
thus if open is called no any interface is running ... and no common
res are used. So remove check on dual emac, it will simplify
code/understanding and will match the name it's called.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index f339268..d261024 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1240,9 +1240,6 @@ static int cpsw_common_res_usage_state(struct cpsw_common *cpsw)
 	u32 i;
 	u32 usage_count = 0;
 
-	if (!cpsw->data.dual_emac)
-		return 0;
-
 	for (i = 0; i < cpsw->data.slaves; i++)
 		if (cpsw->slaves[i].open_stat)
 			usage_count++;
-- 
2.7.4
