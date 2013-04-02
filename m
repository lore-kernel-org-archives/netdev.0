From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 3/4] qlcnic: Fix sparse warnings.
Date: Tue,  2 Apr 2013 11:34:42 -0400
Message-ID: <1364916883-10109-4-git-send-email-rajesh.borundia@qlogic.com>
References: <1364916883-10109-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:23713 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1761372Ab3DBP5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 11:57:51 -0400
In-Reply-To: <1364916883-10109-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

warning: 'pf_info.max_tx_ques' may be used uninitialized in this function
[-Wmaybe-uninitialized]

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index d6ac7dc..bed5056 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -156,6 +156,7 @@ static int qlcnic_sriov_get_pf_info(struct qlcnic_adapter *adapter,
 	npar_info->max_local_ipv6_addrs = LSW(cmd.rsp.arg[8]);
 	npar_info->max_remote_ipv6_addrs = MSW(cmd.rsp.arg[8]);
 
+	qlcnic_sriov_pf_set_ff_max_res(adapter, npar_info);
 	dev_info(&adapter->pdev->dev,
 		 "\n\ttotal_pf: %d,\n"
 		 "\n\ttotal_rss_engines: %d max_vports: %d max_tx_ques %d,\n"
@@ -376,8 +377,6 @@ static int qlcnic_sriov_pf_init(struct qlcnic_adapter *adapter)
 	if (err)
 		goto delete_vport;
 
-	qlcnic_sriov_pf_set_ff_max_res(adapter, &pf_info);
-
 	err = qlcnic_get_nic_info(adapter, &nic_info, func);
 	if (err)
 		goto delete_vport;
-- 
1.6.3.3
