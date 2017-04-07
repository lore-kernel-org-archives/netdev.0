From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next V2 1/7] s390/qeth: use QDIO_*_QFMT defines
Date: Fri,  7 Apr 2017 09:15:32 +0200
Message-ID: <20170407071538.63253-2-ubraun@linux.vnet.ibm.com>
References: <20170407071538.63253-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:35334 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754221AbdDGHPx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 03:15:53 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3778fA8108008
        for <netdev@vger.kernel.org>; Fri, 7 Apr 2017 03:15:48 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29nwqdwvj0-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 03:15:47 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 7 Apr 2017 08:15:45 +0100
In-Reply-To: <20170407071538.63253-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

better use the constant definitions.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 9a5f99c..7142204 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4775,12 +4775,10 @@ static int qeth_query_card_info(struct qeth_card *card,
 
 static inline int qeth_get_qdio_q_format(struct qeth_card *card)
 {
-	switch (card->info.type) {
-	case QETH_CARD_TYPE_IQD:
-		return 2;
-	default:
-		return 0;
-	}
+	if (card->info.type == QETH_CARD_TYPE_IQD)
+		return QDIO_IQDIO_QFMT;
+	else
+		return QDIO_QETH_QFMT;
 }
 
 static void qeth_determine_capabilities(struct qeth_card *card)
-- 
2.10.2
