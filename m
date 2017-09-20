From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 01/10] net/smc: add missing dev_put
Date: Wed, 20 Sep 2017 13:58:04 +0200
Message-ID: <20170920115813.63745-2-ubraun@linux.vnet.ibm.com>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46108 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751785AbdITL60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 07:58:26 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8KBthYq055217
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:26 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d3mf8vxeb-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:26 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 20 Sep 2017 12:58:23 +0100
In-Reply-To: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

In the infiniband part, SMC currently uses get_netdev which calls
dev_hold on the returned net device. However, the SMC code never calls
dev_put on that net device resulting in a wrong reference count.

This patch adds a dev_put after the usage of the net device to fix the
issue.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/smc_ib.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index 547e0e113b17..0b5852299158 100644
--- a/net/smc/smc_ib.c
+++ b/net/smc/smc_ib.c
@@ -380,6 +380,7 @@ static int smc_ib_fill_gid_and_mac(struct smc_ib_device *smcibdev, u8 ibport)
 	ndev = smcibdev->ibdev->get_netdev(smcibdev->ibdev, ibport);
 	if (ndev) {
 		memcpy(&smcibdev->mac, ndev->dev_addr, ETH_ALEN);
+		dev_put(ndev);
 	} else if (!rc) {
 		memcpy(&smcibdev->mac[ibport - 1][0],
 		       &smcibdev->gid[ibport - 1].raw[8], 3);
-- 
2.13.5
