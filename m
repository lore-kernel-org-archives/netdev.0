From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 4/7] qlcnic: Allow vlan0 traffic
Date: Fri, 21 Feb 2014 13:20:13 -0500
Message-ID: <1393006816-20294-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1393006816-20294-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:27937 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751508AbaBUSzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 13:55:48 -0500
In-Reply-To: <1393006816-20294-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Adapter allows vlan0 traffic in case of SR-IOV after setting
  QLC_SRIOV_ALLOW_VLAN0 bit even though we do not add vlan0 filters.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 09acf15..a28460c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -17,6 +17,7 @@
 #define QLC_MAC_STAR_DEL	7
 #define QLC_VF_FLOOD_BIT	BIT_16
 #define QLC_FLOOD_MODE		0x5
+#define QLC_SRIOV_ALLOW_VLAN0	BIT_19
 
 static int qlcnic_sriov_pf_get_vport_handle(struct qlcnic_adapter *, u8);
 
@@ -337,8 +338,11 @@ static int qlcnic_sriov_pf_cfg_vlan_filtering(struct qlcnic_adapter *adapter,
 		return err;
 
 	cmd.req.arg[1] = 0x4;
-	if (enable)
+	if (enable) {
 		cmd.req.arg[1] |= BIT_16;
+		if (qlcnic_84xx_check(adapter))
+			cmd.req.arg[1] |= QLC_SRIOV_ALLOW_VLAN0;
+	}
 
 	err = qlcnic_issue_cmd(adapter, &cmd);
 	if (err)
-- 
1.8.1.4
