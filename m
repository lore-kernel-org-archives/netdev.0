From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: bcmsysport: use napi_complete_done()
Date: Wed, 20 Apr 2016 11:37:09 -0700
Message-ID: <1461177429-23553-3-git-send-email-f.fainelli@gmail.com>
References: <1461177429-23553-1-git-send-email-f.fainelli@gmail.com>
Cc: edumazet@google.com, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:32879 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbcDTSjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 14:39:25 -0400
Received: by mail-pf0-f174.google.com with SMTP id 184so21052156pff.0
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 11:39:25 -0700 (PDT)
In-Reply-To: <1461177429-23553-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using napi_complete_done(), we allow fine tuning of
/sys/class/net/ethX/gro_flush_timeout for higher GRO aggregation
efficiency for a Gbit NIC.

Check commit 24d2e4a50737 ("tg3: use napi_complete_done()") for details.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 9e3ec739d860..30b0c2895a56 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -831,7 +831,7 @@ static int bcm_sysport_poll(struct napi_struct *napi, int budget)
 	rdma_writel(priv, priv->rx_c_index, RDMA_CONS_INDEX);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		/* re-enable RX interrupts */
 		intrl2_0_mask_clear(priv, INTRL2_0_RDMA_MBDONE);
 	}
-- 
2.1.0
