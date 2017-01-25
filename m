From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net 5/5] ibmvnic: init completion struct before requesting long term mapped buffers
Date: Wed, 25 Jan 2017 15:02:23 -0600
Message-ID: <1485378143-5084-5-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, wvoigt@us.ibm.com,
        nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:41116 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752021AbdAYVCf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 16:02:35 -0500
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0PKwgEs079059
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 16:02:35 -0500
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2872ru1s4b-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 16:02:34 -0500
Received: from localhost
        by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 25 Jan 2017 16:02:33 -0500
In-Reply-To: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize this completion structure before requesting that
a buffer be long-term mapped . This fix resolves a bug where firmware
sends a response before the structure is initialized.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index ec6c5fe..d1ffc61 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -189,9 +189,9 @@ static int alloc_long_term_buff(struct ibmvnic_adapter *adapter,
 	}
 	ltb->map_id = adapter->map_id;
 	adapter->map_id++;
+	init_completion(&adapter->fw_done);
 	send_request_map(adapter, ltb->addr,
 			 ltb->size, ltb->map_id);
-	init_completion(&adapter->fw_done);
 	wait_for_completion(&adapter->fw_done);
 	return 0;
 }
-- 
1.8.3.1
