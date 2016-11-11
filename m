From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net 2/2] ibmvnic: Fix size of debugfs name buffer
Date: Fri, 11 Nov 2016 11:00:46 -0600
Message-ID: <1478883646-10760-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1478883646-10760-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: mwb@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57231 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756737AbcKKRA5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 12:00:57 -0500
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uABGwrFL120743
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 12:00:56 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
        by mx0a-001b2d01.pphosted.com with ESMTP id 26neaa0jet-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 12:00:56 -0500
Received: from localhost
        by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Fri, 11 Nov 2016 10:00:53 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
        by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D0A043E40063
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 10:00:48 -0700 (MST)
In-Reply-To: <1478883646-10760-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This mistake was causing debugfs directory creation
failures when multiple ibmvnic devices were probed.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 921c40f..4f3281a 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3705,7 +3705,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	struct net_device *netdev;
 	unsigned char *mac_addr_p;
 	struct dentry *ent;
-	char buf[16]; /* debugfs name buf */
+	char buf[17]; /* debugfs name buf */
 	int rc;
 
 	dev_dbg(&dev->dev, "entering ibmvnic_probe for UA 0x%x\n",
-- 
1.8.3.1
