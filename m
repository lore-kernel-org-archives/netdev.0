From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 13/13] s390/qeth: fix indentation in qeth_l3_arp_query
Date: Thu, 16 Jun 2016 16:19:03 +0200
Message-ID: <1466086743-55484-14-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60374 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754501AbcFPOTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:19:40 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GEIw72096626
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:40 -0400
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23kqshyj9y-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:39 -0400
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 16 Jun 2016 15:19:35 +0100
In-Reply-To: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Ott <sebott@linux.vnet.ibm.com>

gcc-6 warns about obviously wrong indentation:
drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_arp_query':
drivers/s390/net/qeth_l3_main.c:2315:3: warning: this 'if' clause does not
guard... [-Wmisleading-indentation]
   if (copy_to_user(udata, qinfo.udata, 4))
   ^~
drivers/s390/net/qeth_l3_main.c:2317:4: note: ...this statement, but the
latter is misleadingly indented as if it is guarded by the 'if'
    goto free_and_out;
    ^~~~

Although this particular case is harmless, fix the indentation to get rid
of that warning and improve readability.

Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 05f764c..bcd324e 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2314,22 +2314,21 @@ static int qeth_l3_arp_query(struct qeth_card *card, char __user *udata)
 	if (rc) {
 		if (copy_to_user(udata, qinfo.udata, 4))
 			rc = -EFAULT;
-			goto free_and_out;
-	} else {
+		goto free_and_out;
+	}
 #ifdef CONFIG_QETH_IPV6
-		if (qinfo.mask_bits & QETH_QARP_WITH_IPV6) {
-			/* fails in case of GuestLAN QDIO mode */
-			qeth_l3_query_arp_cache_info(card, QETH_PROT_IPV6,
-				&qinfo);
-		}
+	if (qinfo.mask_bits & QETH_QARP_WITH_IPV6) {
+		/* fails in case of GuestLAN QDIO mode */
+		qeth_l3_query_arp_cache_info(card, QETH_PROT_IPV6, &qinfo);
+	}
 #endif
-		if (copy_to_user(udata, qinfo.udata, qinfo.udata_len)) {
-			QETH_CARD_TEXT(card, 4, "qactf");
-			rc = -EFAULT;
-			goto free_and_out;
-		}
-		QETH_CARD_TEXT(card, 4, "qacts");
+	if (copy_to_user(udata, qinfo.udata, qinfo.udata_len)) {
+		QETH_CARD_TEXT(card, 4, "qactf");
+		rc = -EFAULT;
+		goto free_and_out;
 	}
+	QETH_CARD_TEXT(card, 4, "qacts");
+
 free_and_out:
 	kfree(qinfo.udata);
 out:
-- 
2.6.6
