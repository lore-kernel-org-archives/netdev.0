From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] rsi: consolidate kmalloc/memset 0 calls to kzalloc
Date: Sat, 19 Dec 2015 17:39:26 +0100
Message-ID: <1450543166-27531-1-git-send-email-hofrat@osadl.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an API consolidation only. The use of kmalloc + memset to 0
is equivalent to kzalloc.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Found by coccinelle script (relaxed version of
scripts/coccinelle/api/alloc/kzalloc-simple.cocci)

Patch was compile tested with: x86_64_defconfig +
CONFIG_RSI_91X=m

Patch is against linux-next (localversion-next is -next-20151218)

 drivers/net/wireless/rsi/rsi_91x_mgmt.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_mgmt.c b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
index 8d110fd..697caab 100644
--- a/drivers/net/wireless/rsi/rsi_91x_mgmt.c
+++ b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
@@ -1023,7 +1023,7 @@ static int rsi_send_auto_rate_request(struct rsi_common *common)
 		return -ENOMEM;
 	}
 
-	selected_rates = kmalloc(2 * RSI_TBL_SZ, GFP_KERNEL);
+	selected_rates = kzalloc(2 * RSI_TBL_SZ, GFP_KERNEL);
 	if (!selected_rates) {
 		rsi_dbg(ERR_ZONE, "%s: Failed in allocation of mem\n",
 			__func__);
@@ -1032,7 +1032,6 @@ static int rsi_send_auto_rate_request(struct rsi_common *common)
 	}
 
 	memset(skb->data, 0, sizeof(struct rsi_auto_rate));
-	memset(selected_rates, 0, 2 * RSI_TBL_SZ);
 
 	auto_rate = (struct rsi_auto_rate *)skb->data;
 
-- 
1.7.10.4
