From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 3/3] NetXen: Fix ping failure of Jumbo frames on MEZ cards.
Date: Mon, 5 Mar 2007 04:57:09 -0800
Message-ID: <200703051257.l25Cv9KM005045@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:18686 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933425AbXCEM5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 07:57:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix ping failure of Jumbo frames on MEZ cards.

Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic_hw.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 693d01a..81ebc81 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -962,7 +962,12 @@ int netxen_nic_set_mtu_gb(struct netxen_
 int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 {
 	new_mtu += NETXEN_NIU_HDRSIZE + NETXEN_NIU_TLRSIZE;
-	netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, new_mtu);
+	if (adapter->portnum == 0)
+		netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, 
+				new_mtu);
+	else if (adapter->portnum == 1)
+		netxen_nic_write_w0(adapter, NETXEN_NIU_XG1_MAX_FRAME_SIZE,
+				new_mtu);
 	return 0;
 }
 
