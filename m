From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net] bnx2x: add missing napi deletion in error path
Date: Fri, 15 Mar 2013 16:27:54 +0100
Message-ID: <1363361274-25754-1-git-send-email-mschmidt@redhat.com>
Cc: Merav Sicron <meravs@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932067Ab3COP15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 11:27:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the hardware initialization fails in bnx2x_nic_load() after adding
napi objects, they would not be deleted. A subsequent attempt to unload
the bnx2x module detects a corruption in the napi list.

Add the missing napi deletion to the error path.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a923bc4..4046f97 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2760,6 +2760,7 @@ load_error2:
 	bp->port.pmf = 0;
 load_error1:
 	bnx2x_napi_disable(bp);
+	bnx2x_del_all_napi(bp);
 
 	/* clear pf_load status, as it was already set */
 	if (IS_PF(bp))
-- 
1.8.1.4
