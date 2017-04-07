From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next V2 3/7] s390/qeth: remove unused return value
Date: Fri,  7 Apr 2017 09:15:34 +0200
Message-ID: <20170407071538.63253-4-ubraun@linux.vnet.ibm.com>
References: <20170407071538.63253-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56053 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754189AbdDGHPv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 03:15:51 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3778qbA127111
        for <netdev@vger.kernel.org>; Fri, 7 Apr 2017 03:15:50 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29nu2dvk75-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 03:15:50 -0400
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 7 Apr 2017 08:15:48 +0100
In-Reply-To: <20170407071538.63253-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

qeth_qdio_output_handler() is the only caller of
qeth_handle_send_error() and doesn't care about the return value.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      | 7 -------
 drivers/s390/net/qeth_core_main.c | 7 +++----
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index d9561e3..d311bdc 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -503,13 +503,6 @@ struct qeth_qdio_info {
 	int default_out_queue;
 };
 
-enum qeth_send_errors {
-	QETH_SEND_ERROR_NONE,
-	QETH_SEND_ERROR_LINK_FAILURE,
-	QETH_SEND_ERROR_RETRY,
-	QETH_SEND_ERROR_KICK_IT,
-};
-
 #define QETH_ETH_MAC_V4      0x0100 /* like v4 */
 #define QETH_ETH_MAC_V6      0x3333 /* like v6 */
 /* tr mc mac is longer, but that will be enough to detect mc frames */
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 510947b..9262d94 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3322,7 +3322,7 @@ void qeth_queue_input_buffer(struct qeth_card *card, int index)
 }
 EXPORT_SYMBOL_GPL(qeth_queue_input_buffer);
 
-static int qeth_handle_send_error(struct qeth_card *card,
+static void qeth_handle_send_error(struct qeth_card *card,
 		struct qeth_qdio_out_buffer *buffer, unsigned int qdio_err)
 {
 	int sbalf15 = buffer->buffer->element[15].sflags;
@@ -3338,15 +3338,14 @@ static int qeth_handle_send_error(struct qeth_card *card,
 	qeth_check_qdio_errors(card, buffer->buffer, qdio_err, "qouterr");
 
 	if (!qdio_err)
-		return QETH_SEND_ERROR_NONE;
+		return;
 
 	if ((sbalf15 >= 15) && (sbalf15 <= 31))
-		return QETH_SEND_ERROR_RETRY;
+		return;
 
 	QETH_CARD_TEXT(card, 1, "lnkfail");
 	QETH_CARD_TEXT_(card, 1, "%04x %02x",
 		       (u16)qdio_err, (u8)sbalf15);
-	return QETH_SEND_ERROR_LINK_FAILURE;
 }
 
 /*
-- 
2.10.2
