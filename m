From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH net-next] bnx2x: Remove open coded carrier check
Date: Tue, 16 May 2017 15:20:56 +0300
Message-ID: <20170516122056.1534-1-leon@kernel.org>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:35790 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752067AbdEPMVF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 08:21:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

There is inline function to test if carrier present,
so it makes open-coded solution redundant.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a851f95c307a..7414ffd70c90 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10303,7 +10303,7 @@ static void bnx2x_sp_rtnl_task(struct work_struct *work)
 	}
 	if (test_and_clear_bit(BNX2X_SP_RTNL_VFPF_CHANNEL_DOWN,
 			       &bp->sp_rtnl_state)){
-		if (!test_bit(__LINK_STATE_NOCARRIER, &bp->dev->state)) {
+		if (netif_carrier_ok(bp->dev)) {
 			bnx2x_tx_disable(bp);
 			BNX2X_ERR("PF indicated channel is not servicable anymore. This means this VF device is no longer operational\n");
 		}
