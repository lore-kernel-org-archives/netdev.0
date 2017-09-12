From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: [PATCH] qed: remove unnecessary call to memset
Date: Tue, 12 Sep 2017 16:49:22 +0530
Message-ID: <1505215162-3917-1-git-send-email-himanshujha199640@gmail.com>
Cc: Ariel.Elior@cavium.com, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Himanshu Jha <himanshujha199640@gmail.com>
To: Yuval.Mintz@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

call to memset to assign 0 value immediately after allocating
memory with kzalloc is unnecesaary as kzalloc allocates the memory
filled with 0 value.

Semantic patch used to resolve this issue:

@@
expression e,e2; constant c;
statement S;
@@

  e = kzalloc(e2, c);
  if(e == NULL) S
- memset(e, 0, e2);

Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index eaca457..8f6ccc0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -1244,7 +1244,6 @@ int qed_dcbx_get_config_params(struct qed_hwfn *p_hwfn,
 	if (!dcbx_info)
 		return -ENOMEM;
 
-	memset(dcbx_info, 0, sizeof(*dcbx_info));
 	rc = qed_dcbx_query_params(p_hwfn, dcbx_info, QED_DCBX_OPERATIONAL_MIB);
 	if (rc) {
 		kfree(dcbx_info);
-- 
2.7.4
