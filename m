From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] qed: Fix a memory allocation failure test in 'qed_mcp_cmd_init()'
Date: Mon,  7 Aug 2017 00:00:17 +0200
Message-ID: <20170806220017.20465-1-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We allocate 'p_info->mfw_mb_cur' and 'p_info->mfw_mb_shadow' but we check
'p_info->mfw_mb_addr' instead of 'p_info->mfw_mb_cur'.

'p_info->mfw_mb_addr' is never 0, because it is initiliazed a few lines
above in 'qed_load_mcp_offsets()'.

Update the test and check the result of the 2 'kzalloc()' instead.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index c1ecce6b9141..376485d99357 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -253,7 +253,7 @@ int qed_mcp_cmd_init(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	size = MFW_DRV_MSG_MAX_DWORDS(p_info->mfw_mb_length) * sizeof(u32);
 	p_info->mfw_mb_cur = kzalloc(size, GFP_KERNEL);
 	p_info->mfw_mb_shadow = kzalloc(size, GFP_KERNEL);
-	if (!p_info->mfw_mb_shadow || !p_info->mfw_mb_addr)
+	if (!p_info->mfw_mb_cur || !p_info->mfw_mb_shadow)
 		goto err;
 
 	return 0;
-- 
2.11.0
