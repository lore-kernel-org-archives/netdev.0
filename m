From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net v2 3/4] qlcnic: Allow any VLAN to be configured from VF.
Date: Mon, 24 Feb 2014 08:54:48 -0500
Message-ID: <1393250089-31104-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1393250089-31104-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39434 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752775AbaBXOaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 09:30:19 -0500
In-Reply-To: <1393250089-31104-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o This patch reverts commit 1414abea048e0835c43600d62808ed8163897227
  (qlcnic: Restrict VF from configuring any VLAN mode.)
  This will allow same multicast address to be used with any VLAN
  instead of programming seperate (MAC, VLAN) tuples in adapter.
  This will help save some multicast filters.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 09acf15..e5277a6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -13,8 +13,6 @@
 #define QLC_VF_MIN_TX_RATE	100
 #define QLC_VF_MAX_TX_RATE	9999
 #define QLC_MAC_OPCODE_MASK	0x7
-#define QLC_MAC_STAR_ADD	6
-#define QLC_MAC_STAR_DEL	7
 #define QLC_VF_FLOOD_BIT	BIT_16
 #define QLC_FLOOD_MODE		0x5
 
@@ -1206,13 +1204,6 @@ static int qlcnic_sriov_validate_cfg_macvlan(struct qlcnic_adapter *adapter,
 	struct qlcnic_vport *vp = vf->vp;
 	u8 op, new_op;
 
-	if (((cmd->req.arg[1] & QLC_MAC_OPCODE_MASK) == QLC_MAC_STAR_ADD) ||
-	    ((cmd->req.arg[1] & QLC_MAC_OPCODE_MASK) == QLC_MAC_STAR_DEL)) {
-		netdev_err(adapter->netdev, "MAC + any VLAN filter not allowed from VF %d\n",
-			   vf->pci_func);
-		return -EINVAL;
-	}
-
 	if (!(cmd->req.arg[1] & BIT_8))
 		return -EINVAL;
 
-- 
1.8.1.4
