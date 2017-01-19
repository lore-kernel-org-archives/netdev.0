From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 1/5] net: ethernet: ti: cpsw: remove dual check from common res usage function
Date: Thu, 19 Jan 2017 18:58:23 +0200
Message-ID: <1484845107-30331-2-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:36727 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753877AbdASRIF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 12:08:05 -0500
Received: by mail-lf0-f51.google.com with SMTP id z134so41353459lff.3
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 09:08:04 -0800 (PST)
In-Reply-To: <1484845107-30331-1-git-send-email-ivan.khoronzhuk@linaro.org>
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
index 02b03ee..296ddf2 100644
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
