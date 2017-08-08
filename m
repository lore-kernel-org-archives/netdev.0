From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Correct 'unused variable' warning in
 build.
Date: Tue, 08 Aug 2017 15:26:18 -0500
Message-ID: <20170808202618.32133.49772.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:57139 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752449AbdHHPj2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 11:39:28 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78FcfPr085520
        for <netdev@vger.kernel.org>; Tue, 8 Aug 2017 11:39:28 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c7g1vrc4x-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 11:39:27 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 8 Aug 2017 11:39:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a248878d7a1d ("ibmvnic: Check for transport event on driver resume")
removed the loop to kick irqs on driver resume but didn't remove the now
unused loop variable 'i'.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index d267aa8..e3c422b 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3995,7 +3995,6 @@ static int ibmvnic_resume(struct device *dev)
 {
 	struct net_device *netdev = dev_get_drvdata(dev);
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
-	int i;
 
 	if (adapter->state != VNIC_OPEN)
 		return 0;
