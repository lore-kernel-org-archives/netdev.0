From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 1/1] bna: PCI Probe Conf Lock Fix
Date: Wed, 21 Sep 2011 17:31:50 -0700
Message-ID: <1316651510-19646-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dan.carpenter@oracle.com>,
	<adapter_linux_open_src_team@blc-10-4.brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37657 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750781Ab1IVAcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 20:32:09 -0400
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id p8M0W8vM030649
	for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 17:32:08 -0700
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.140.11])
	by mx0b-000f0801.pphosted.com with ESMTP id yysuq80sv-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 17:32:07 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If register_netdev() fails now, then we call mutex_unlock(&bnad->conf_mutex);
on the error path, but it's already unlocked. So we acquire the lock in error
path which will be later unlocked after the cleanup.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index abca139..db6c097 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3359,6 +3359,7 @@ probe_success:
 	return 0;
 
 probe_uninit:
+	mutex_lock(&bnad->conf_mutex);
 	bnad_res_free(bnad, &bnad->mod_res_info[0], BNA_MOD_RES_T_MAX);
 disable_ioceth:
 	bnad_ioceth_disable(bnad);
-- 
1.7.1
