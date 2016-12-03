From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] netdev: broadcom: propagate error code
Date: Sat,  3 Dec 2016 17:56:17 +0800
Message-ID: <1480758977-4234-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: "David S. Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        Prashant Sreedharan <prashant.sreedharan@broadcom.com>,
        Satish Baddipadige <sbaddipa@broadcom.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Function bnxt_hwrm_stat_ctx_alloc() always returns 0, even if the call
to _hwrm_send_message() fails. It may be better to propagate the errors
to the caller of bnxt_hwrm_stat_ctx_alloc().

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188661

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ee1a803..f08a20b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4120,7 +4120,7 @@ static int bnxt_hwrm_stat_ctx_alloc(struct bnxt *bp)
 		bp->grp_info[i].fw_stats_ctx = cpr->hw_stats_ctx_id;
 	}
 	mutex_unlock(&bp->hwrm_cmd_lock);
-	return 0;
+	return rc;
 }
 
 static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
-- 
1.9.1
