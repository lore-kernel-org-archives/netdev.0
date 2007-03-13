From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 1/2] NetXen: Bug fix for Jumbo frames on XG card
Date: Tue, 13 Mar 2007 04:13:13 -0800
Message-ID: <200703131213.l2DCDDhN008925@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:28658 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965705AbXCMMNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 08:13:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Set the MTU for the right port depending upon the port number
for XG cards.

Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic_hw.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 1be5570..6537574 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -822,7 +822,10 @@ int netxen_nic_set_mtu_xgb(struct netxen
 {
 	struct netxen_adapter *adapter = port->adapter;
 	new_mtu += NETXEN_NIU_HDRSIZE + NETXEN_NIU_TLRSIZE;
-	netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, new_mtu);
+	if (port->portnum == 0)
+	    netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, new_mtu);
+	else if (port->portnum == 1)
+	    netxen_nic_write_w0(adapter, NETXEN_NIU_XG1_MAX_FRAME_SIZE, new_mtu);
 	return 0;
 }
 
