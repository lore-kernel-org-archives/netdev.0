From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 3/3] qlcnic: Initialize dcbnl_ops before register_netdev
Date: Mon, 4 Aug 2014 11:51:18 -0400
Message-ID: <1407167478-22277-4-git-send-email-rajesh.borundia@qlogic.com>
References: <1407167478-22277-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:50930 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752184AbaHDQXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 12:23:23 -0400
In-Reply-To: <1407167478-22277-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Initialization of dcbnl_ops after register netdev may result in
  dcbnl_ops not getting set before it is being accessed from open.
  So, moving it before register_netdev.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 158e1d9..3187bc0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2323,14 +2323,14 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 	if (err)
 		return err;
 
+	qlcnic_dcb_init_dcbnl_ops(adapter->dcb);
+
 	err = register_netdev(netdev);
 	if (err) {
 		dev_err(&pdev->dev, "failed to register net device\n");
 		return err;
 	}
 
-	qlcnic_dcb_init_dcbnl_ops(adapter->dcb);
-
 	return 0;
 }
 
-- 
1.6.3.3
