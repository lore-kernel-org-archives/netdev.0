From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/7] s390/qeth: fix up ssqd tracing
Date: Wed,  5 Apr 2017 10:40:10 +0200
Message-ID: <20170405084015.35772-3-ubraun@linux.vnet.ibm.com>
References: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:55933 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754577AbdDEIkc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 04:40:32 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v358dF0B139066
        for <netdev@vger.kernel.org>; Wed, 5 Apr 2017 04:40:31 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29m51p2270-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 04:40:31 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 5 Apr 2017 09:40:28 +0100
In-Reply-To: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
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
index 3b3cb3b..95bd5d8 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4816,8 +4816,9 @@ static void qeth_determine_capabilities(struct qeth_card *card)
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
