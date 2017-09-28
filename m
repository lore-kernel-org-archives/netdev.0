From: Mick Tarsel <mjtarsel@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Set state UP
Date: Thu, 28 Sep 2017 13:53:18 -0700
Message-ID: <1506631998-12670-1-git-send-email-mjtarsel@linux.vnet.ibm.com>
Cc: tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:44816 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751008AbdI1Uxv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 16:53:51 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8SKqwAB111056
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 16:53:50 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d95c1b24f-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 16:53:50 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <mjtarsel@linux.vnet.ibm.com>;
        Thu, 28 Sep 2017 16:53:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

State is initially reported as UNKNOWN. Before register call
netif_carrier_off(). Once the device is opened, call netif_carrier_on() in
order to set the state to UP.

Signed-off-by: Mick Tarsel <mjtarsel@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index cb8182f..4bc14a9 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -927,6 +927,7 @@ static int ibmvnic_open(struct net_device *netdev)
 	}
 
 	rc = __ibmvnic_open(netdev);
+	netif_carrier_on(netdev);
 	mutex_unlock(&adapter->reset_lock);
 
 	return rc;
@@ -3899,6 +3900,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	if (rc)
 		goto ibmvnic_init_fail;
 
+	netif_carrier_off(netdev);
 	rc = register_netdev(netdev);
 	if (rc) {
 		dev_err(&dev->dev, "failed to register netdev rc=%d\n", rc);
-- 
1.8.3.1
