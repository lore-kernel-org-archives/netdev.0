From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/5] qed: Allow more than 16 VFs
Date: Sun, 15 May 2016 14:48:08 +0300
Message-ID: <1463312889-19351-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:57535 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754192AbcEOLs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 07:48:28 -0400
In-Reply-To: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In multi-function modes, PFs are currently limited to using 16 VFs -
But that limitation would also currently apply in case there's a single
PCI function exposed, where no such restriction should have existed.

This lifts the restriction for the default mode; User should be able
to start the maximum number of VFs as appear in the PCI config space.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index a977f39..c325ee8 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -3099,6 +3099,9 @@ static int qed_sriov_enable(struct qed_dev *cdev, int num)
 			goto err;
 		}
 
+		if (IS_MF_DEFAULT(hwfn))
+			limit = MAX_NUM_VFS_BB / hwfn->num_funcs_on_engine;
+
 		memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
 		qed_int_get_num_sbs(hwfn, &sb_cnt_info);
 		num_sbs = min_t(int, sb_cnt_info.sb_free_blk, limit);
-- 
1.9.3
