From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/9] s390/qeth: remove unused code in qdio_establish_cq()
Date: Mon, 18 Sep 2017 21:18:17 +0200
Message-ID: <20170918191822.65142-5-jwi@linux.vnet.ibm.com>
References: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54231 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750964AbdIRTT3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:19:29 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8IJJFQj104946
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:19:29 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d2m1r0jym-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:19:28 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 18 Sep 2017 20:19:26 +0100
In-Reply-To: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Storing the number of input buffers into 'i' has no effect, it is
immediately re-assigned in the next line.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index bae7440abc01..77032801e30b 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4923,7 +4923,6 @@ static void qeth_qdio_establish_cq(struct qeth_card *card,
 	if (card->options.cq == QETH_CQ_ENABLED) {
 		int offset = QDIO_MAX_BUFFERS_PER_Q *
 			     (card->qdio.no_in_queues - 1);
-		i = QDIO_MAX_BUFFERS_PER_Q * (card->qdio.no_in_queues - 1);
 		for (i = 0; i < QDIO_MAX_BUFFERS_PER_Q; ++i) {
 			in_sbal_ptrs[offset + i] = (struct qdio_buffer *)
 				virt_to_phys(card->qdio.c_q->bufs[i].buffer);
-- 
2.13.5
