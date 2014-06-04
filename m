From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH v2 net] qlcnic: Initialize mailbox cmd structure to zero
Date: Wed, 4 Jun 2014 03:40:54 -0400
Message-ID: <1401867654-16691-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:54819 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750773AbaFDIKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 04:10:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Uninitialzed fields in mailbox command structure
  caused commands to time out randomly due to garbage
  values so initialize it to zero.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
Changes in v2: Initialized cmd structure where it is allocated as
	       per David Miller's review comment.
---
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 6afe9c1..d9216af 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -454,6 +454,7 @@ static int qlcnic_sriov_get_vf_acl(struct qlcnic_adapter *adapter)
 	struct qlcnic_cmd_args cmd;
 	int ret = 0;
 
+	memset(&cmd, 0, sizeof(cmd));
 	ret = qlcnic_sriov_alloc_bc_mbx_args(&cmd, QLCNIC_BC_CMD_GET_ACL);
 	if (ret)
 		return ret;
@@ -1441,6 +1442,7 @@ static int qlcnic_sriov_channel_cfg_cmd(struct qlcnic_adapter *adapter, u8 cmd_o
 	struct qlcnic_vf_info *vf = &adapter->ahw->sriov->vf_info[0];
 	int ret;
 
+	memset(&cmd, 0, sizeof(cmd));
 	if (qlcnic_sriov_alloc_bc_mbx_args(&cmd, cmd_op))
 		return -ENOMEM;
 
@@ -1998,6 +2000,7 @@ int qlcnic_sriov_cfg_vf_guest_vlan(struct qlcnic_adapter *adapter,
 	struct qlcnic_cmd_args cmd;
 	int ret;
 
+	memset(&cmd, 0, sizeof(cmd));
 	if (vid == 0)
 		return 0;
 
-- 
1.6.3.3
