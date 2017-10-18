From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 12/13] s390/qeth: support GRO flush timer
Date: Wed, 18 Oct 2017 17:40:24 +0200
Message-ID: <20171018154025.73630-13-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:41284 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750979AbdJRPlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:41:06 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFejDq133222
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:41:06 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dp6ugt5m5-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:41:02 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:52 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to napi_complete_done(), and thus enable delayed GRO flushing.
The timeout is configured via /sys/class/net/<if>/gro_flush_timeout.

Default timeout is 0, so no change in behaviour.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 8855bc8534d2..98b7e1ce0dd1 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5370,7 +5370,7 @@ int qeth_poll(struct napi_struct *napi, int budget)
 		}
 	}
 
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 	if (qdio_start_irq(card->data.ccwdev, 0))
 		napi_schedule(&card->napi);
 out:
-- 
2.13.5
