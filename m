From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Return failure on attempted mtu change
Date: Tue, 6 Jun 2017 16:55:52 -0500
Message-ID: <103eefae-37aa-a30a-4027-5a9c8def3d3f@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>,
        John Allen <jallen@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:55137 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751436AbdFFV4C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 17:56:02 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v56LsgT7002849
        for <netdev@vger.kernel.org>; Tue, 6 Jun 2017 17:56:02 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2awynj57xn-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 17:56:02 -0400
Received: from localhost
        by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Tue, 6 Jun 2017 15:56:01 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing the mtu is currently not supported in the ibmvnic driver.

Implement .ndo_change_mtu in the driver so that attempting to use ifconfig
to change the mtu will fail and present the user with an error message.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4f2d329..8ff6c74 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1468,6 +1468,11 @@ static void ibmvnic_netpoll_controller(struct net_device *dev)
 }
 #endif

+static int ibmvnic_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	return -EOPNOTSUPP;
+}
+
 static const struct net_device_ops ibmvnic_netdev_ops = {
 	.ndo_open		= ibmvnic_open,
 	.ndo_stop		= ibmvnic_close,
@@ -1479,6 +1484,7 @@ static void ibmvnic_netpoll_controller(struct net_device *dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ibmvnic_netpoll_controller,
 #endif
+	.ndo_change_mtu		= ibmvnic_change_mtu,
 };

 /* ethtool functions */
