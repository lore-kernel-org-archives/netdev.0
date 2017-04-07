From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next V2 2/7] s390/qeth: fix up ssqd tracing
Date: Fri,  7 Apr 2017 09:15:33 +0200
Message-ID: <20170407071538.63253-3-ubraun@linux.vnet.ibm.com>
References: <20170407071538.63253-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52536 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754154AbdDGHPz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 03:15:55 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3778ruC134037
        for <netdev@vger.kernel.org>; Fri, 7 Apr 2017 03:15:49 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29p3veq1k4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 03:15:49 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 7 Apr 2017 08:15:48 +0100
In-Reply-To: <20170407071538.63253-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

The ac fields are bitmaps, so format them as hex.
While at it, also print the ac2 field.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 7142204..510947b 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4817,8 +4817,9 @@ static void qeth_determine_capabilities(struct qeth_card *card)
 		QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
 
 	QETH_DBF_TEXT_(SETUP, 2, "qfmt%d", card->ssqd.qfmt);
-	QETH_DBF_TEXT_(SETUP, 2, "%d", card->ssqd.qdioac1);
-	QETH_DBF_TEXT_(SETUP, 2, "%d", card->ssqd.qdioac3);
+	QETH_DBF_TEXT_(SETUP, 2, "ac1:%02x", card->ssqd.qdioac1);
+	QETH_DBF_TEXT_(SETUP, 2, "ac2:%04x", card->ssqd.qdioac2);
+	QETH_DBF_TEXT_(SETUP, 2, "ac3:%04x", card->ssqd.qdioac3);
 	QETH_DBF_TEXT_(SETUP, 2, "icnt%d", card->ssqd.icnt);
 	if (!((card->ssqd.qfmt != QDIO_IQDIO_QFMT) ||
 	    ((card->ssqd.qdioac1 & CHSC_AC1_INITIATE_INPUTQ) == 0) ||
-- 
2.10.2
