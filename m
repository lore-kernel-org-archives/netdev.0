From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net] bnx2x: Don't log mc removal needlessly
Date: Sat, 24 Jun 2017 15:37:00 +0300
Message-ID: <20170624123700.8762-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0045.outbound.protection.outlook.com ([104.47.34.45]:38497
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751291AbdFXMhe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Jun 2017 08:37:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When mc configuration changes bnx2x_config_mcast() can return 0 for
success, negative for failure and positive for benign reason preventing
its immediate work, e.g., when the command awaits the completion of
a previously sent command.

When removing all configured macs on a 578xx adapter, if a positive
value would be returned driver would errneously log it as an error.

Fixes: c7b7b483ccc9 ("bnx2x: Don't flush multicast MACs")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
Dave,

Please consider applying this to 'net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a851f95..349a465 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12729,7 +12729,7 @@ static int bnx2x_set_mc_list(struct bnx2x *bp)
 	} else {
 		/* If no mc addresses are required, flush the configuration */
 		rc = bnx2x_config_mcast(bp, &rparam, BNX2X_MCAST_CMD_DEL);
-		if (rc)
+		if (rc < 0)
 			BNX2X_ERR("Failed to clear multicast configuration %d\n",
 				  rc);
 	}
-- 
2.9.4
