From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] qed: do not use unitialized variable
Date: Sun, 31 Jul 2016 13:24:52 +0200
Message-ID: <1469964292-3231-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	everest-linux-l2@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not write random bytes from the kernel stack when
calling qed_wr.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index b26fe26..151cbf9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -888,7 +888,7 @@ static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 
 	if (hw_mode & (1 << MODE_MF_SI)) {
 		u8 pf_id = 0;
-		u32 val;
+		u32 val = 0;
 
 		if (!qed_hw_init_first_eth(p_hwfn, p_ptt, &pf_id)) {
 			if (p_hwfn->rel_pf_id == pf_id) {
-- 
2.8.1
