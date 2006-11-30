From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 5/5] NetXen:  Fix cast error
Date: Thu, 30 Nov 2006 10:53:16 -0800
Message-ID: <20061130185316.GA32326@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:15024 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1031214AbWK3SxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 13:53:21 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAUIrKGj024910
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 13:53:20 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAUIrKVB225656
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 13:53:20 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAUIrJ3G032145
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 13:53:20 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix for pointer casting error.

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

diff -Nupr netdev-2.6/drivers/net/netxen.four/netxen_nic_hw.c netdev-2.6/drivers/net/netxen/netxen_nic_hw.c
--- netdev-2.6/drivers/net/netxen.four/netxen_nic_hw.c	2006-11-30 10:06:24.000000000 -0800
+++ netdev-2.6/drivers/net/netxen/netxen_nic_hw.c	2006-11-30 10:31:00.000000000 -0800
@@ -867,7 +867,7 @@ void netxen_nic_set_link_parameters(stru
 {
 	struct netxen_adapter *adapter = port->adapter;
 	__le32 status;
-	u16 autoneg;
+	__le32 autoneg = 0;
 	__le32 mode;
 
 	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, &mode);
@@ -907,7 +907,7 @@ void netxen_nic_set_link_parameters(stru
 				    && adapter->
 				    phy_read(adapter, port->portnum,
 					     NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-					     (__le32 *) & autoneg) != 0)
+					     &autoneg) != 0)
 					port->link_autoneg = autoneg;
 			} else
 				goto link_down;
-- 
Don Fry
brazilnut@us.ibm.com
