From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: macb: remove redundant assignment to variable work_done
Date: Tue, 31 Oct 2017 14:23:24 +0000
Message-ID: <20171031142324.25740-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@microchip.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45897 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932196AbdJaOX0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 10:23:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Variable work_done is set to zero and this value is never read, instead
it is set to another value a few statements later.  Remove the redundant
assignment. Cleans up clang warning:

drivers/net/ethernet/cadence/macb_main.c:1221:2: warning: Value stored
to 'work_done' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/cadence/macb_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb_main.c b/drivers/net/ethernet/cadence/macb_main.c
index 6df2cad61647..5dafcde67e45 100644
--- a/drivers/net/ethernet/cadence/macb_main.c
+++ b/drivers/net/ethernet/cadence/macb_main.c
@@ -1218,8 +1218,6 @@ static int macb_poll(struct napi_struct *napi, int budget)
 	status = macb_readl(bp, RSR);
 	macb_writel(bp, RSR, status);
 
-	work_done = 0;
-
 	netdev_vdbg(bp->dev, "poll: status = %08lx, budget = %d\n",
 		    (unsigned long)status, budget);
 
-- 
2.14.1
