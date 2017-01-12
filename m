From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 07/12] s390/qeth: don't convert return code twice
Date: Thu, 12 Jan 2017 15:48:38 +0100
Message-ID: <20170112144843.33463-8-ubraun@linux.vnet.ibm.com>
References: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:46203 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750770AbdALOtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:49:06 -0500
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CEmn3G142578
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:48:59 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27xaca42tk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:48:59 -0500
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 14:48:57 -0000
In-Reply-To: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

qeth_l2_send_groupmac() already translates the return code, so
calling qeth_setdel_makerc() a second time only produces garbage.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 3025f56..38fae10 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -210,8 +210,7 @@ static int qeth_l2_write_mac(struct qeth_card *card, struct qeth_mac *mac)
 				qeth_l2_send_setdelmac(card, mac->mac_addr,
 						IPA_CMD_SETVMAC));
 	} else {
-		rc = qeth_setdel_makerc(card,
-				qeth_l2_send_setgroupmac(card, mac->mac_addr));
+		rc = qeth_l2_send_setgroupmac(card, mac->mac_addr);
 	}
 	return rc;
 }
-- 
2.8.4
