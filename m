From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 4/5] qlcnic: Fix number of rings when we fall back from msix to legacy.
Date: Fri, 21 Feb 2014 01:23:07 -0500
Message-ID: <1392963788-18341-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1392963788-18341-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:55889 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750884AbaBUG6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 01:58:41 -0500
In-Reply-To: <1392963788-18341-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o Driver was not re-setting sds ring count to 1 after failing
   to allocate msi-x interrupts.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 4146664..27c4f13 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -340,6 +340,7 @@ int qlcnic_83xx_setup_intr(struct qlcnic_adapter *adapter)
 			if (qlcnic_sriov_vf_check(adapter))
 				return -EINVAL;
 			num_msix = 1;
+			adapter->drv_sds_rings = QLCNIC_SINGLE_RING;
 			adapter->drv_tx_rings = QLCNIC_SINGLE_RING;
 		}
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index e10fc8e..1222865 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -816,6 +816,7 @@ static int qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter)
 
 		if (!(adapter->flags & QLCNIC_MSIX_ENABLED)) {
 			qlcnic_disable_multi_tx(adapter);
+			adapter->drv_sds_rings = QLCNIC_SINGLE_RING;
 
 			err = qlcnic_enable_msi_legacy(adapter);
 			if (err)
-- 
1.8.1.4
