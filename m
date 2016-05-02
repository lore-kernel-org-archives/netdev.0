From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 1/1] qed: Apply tunnel configurations after PF start
Date: Mon, 2 May 2016 06:16:04 -0400
Message-ID: <1462184164-22650-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51484 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753456AbcEBK6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 06:58:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Configure and enable various tunnels on the
adapter after PF start.

This change was missed as a part of
'commit 464f664501816ef5fbbc00b8de96f4ae5a1c9325
("qed: Add infrastructure support for tunneling")'

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <yuval.mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
index 9f9bc10..e1e2344 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp_commands.c
@@ -362,7 +362,15 @@ int qed_sp_pf_start(struct qed_hwfn *p_hwfn,
 		   sb, sb_index,
 		   p_ramrod->outer_tag);
 
-	return qed_spq_post(p_hwfn, p_ent, NULL);
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+	if (p_tunn) {
+		qed_set_hw_tunn_mode(p_hwfn, p_hwfn->p_main_ptt,
+				     p_tunn->tunn_mode);
+		p_hwfn->cdev->tunn_mode = p_tunn->tunn_mode;
+	}
+
+	return rc;
 }
 
 /* Set pf update ramrod command params */
-- 
2.7.2
