From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH 3/3 net] ibmvnic: Update MTU after device initialization
Date: Mon, 17 Oct 2016 15:28:10 -0500
Message-ID: <1476736090-13588-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1476736090-13588-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52220 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1759389AbcJQU2m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 16:28:42 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9HKSW9C053380
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:28:32 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2653nfwn7e-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:28:31 -0400
Received: from localhost
        by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Mon, 17 Oct 2016 14:28:27 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
        by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A02FC19D8051
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 14:27:50 -0600 (MDT)
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
        by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9HKSOvg14221658
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 13:28:24 -0700
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 82B8678047
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 14:28:24 -0600 (MDT)
Received: from tlfalcon-workstation.ibm.com (unknown [9.65.83.172])
        by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTP id 42D7878056
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 14:28:21 -0600 (MDT)
In-Reply-To: <1476736090-13588-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible for the MTU to be changed during the initialization
process with the VNIC Server.  Ensure that the net device is updated 
to reflect the new MTU.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 928bf8a..213162d 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3654,6 +3654,7 @@ static void handle_crq_init_rsp(struct work_struct *work)
 		goto task_failed;
 
 	netdev->real_num_tx_queues = adapter->req_tx_queues;
+	netdev->mtu = adapter->req_mtu;
 
 	if (adapter->failover) {
 		adapter->failover = false;
@@ -3792,6 +3793,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	}
 
 	netdev->real_num_tx_queues = adapter->req_tx_queues;
+	netdev->mtu = adapter->req_mtu;
 
 	rc = register_netdev(netdev);
 	if (rc) {
-- 
2.7.4
