From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 6/8] qlcnic: Fix SR-IOV cleanup code path
Date: Fri, 10 Jan 2014 11:48:57 -0500
Message-ID: <1389372539-13753-7-git-send-email-shahed.shaikh@qlogic.com>
References: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:3825 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753146AbaAJRXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 12:23:23 -0500
In-Reply-To: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Add __QLCNIC_SRIOV_ENABLE bit check before doing SRIOV cleanup

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index bf8fca7..f998fdc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -277,9 +277,7 @@ static void qlcnic_sriov_vf_cleanup(struct qlcnic_adapter *adapter)
 
 void qlcnic_sriov_cleanup(struct qlcnic_adapter *adapter)
 {
-	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
-
-	if (!sriov)
+	if (!test_bit(__QLCNIC_SRIOV_ENABLE, &adapter->state))
 		return;
 
 	qlcnic_sriov_free_vlans(adapter);
-- 
1.8.3.1
