From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 2/4] qlcnic: Fix initialization of vlan list.
Date: Tue, 28 Jan 2014 11:55:28 -0500
Message-ID: <1390928130-10710-3-git-send-email-rajesh.borundia@qlogic.com>
References: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34107 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755201AbaA1RaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 12:30:03 -0500
In-Reply-To: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Do not re-initialize vlan list in case of adapter reset.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 17a1ca2..0638c18 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -448,8 +448,7 @@ static int qlcnic_sriov_set_guest_vlan_mode(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-static int qlcnic_sriov_get_vf_acl(struct qlcnic_adapter *adapter,
-				   struct qlcnic_info *info)
+static int qlcnic_sriov_get_vf_acl(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_sriov *sriov = adapter->ahw->sriov;
 	struct qlcnic_cmd_args cmd;
@@ -495,10 +494,6 @@ static int qlcnic_sriov_vf_init_driver(struct qlcnic_adapter *adapter)
 	if (err)
 		return -EIO;
 
-	err = qlcnic_sriov_get_vf_acl(adapter, &nic_info);
-	if (err)
-		return err;
-
 	if (qlcnic_83xx_get_port_info(adapter))
 		return -EIO;
 
@@ -555,6 +550,10 @@ static int qlcnic_sriov_setup_vf(struct qlcnic_adapter *adapter,
 	if (err)
 		goto err_out_send_channel_term;
 
+	err = qlcnic_sriov_get_vf_acl(adapter);
+	if (err)
+		goto err_out_send_channel_term;
+
 	err = qlcnic_setup_netdev(adapter, adapter->netdev, pci_using_dac);
 	if (err)
 		goto err_out_send_channel_term;
-- 
1.5.6
