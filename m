From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 13/13] s390/qeth: don't dump control cmd twice
Date: Wed, 18 Oct 2017 17:40:25 +0200
Message-ID: <20171018154025.73630-14-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:42068 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751927AbdJRPk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:56 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFdYlB147382
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:55 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dp6squ7em-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:55 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:54 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few lines down, qeth_prepare_control_data() makes further changes to
the control cmd buffer, and then also writes a trace entry for it.
So the first entry just pollutes the trace file with intermediate data,
drop it.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 98b7e1ce0dd1..457a4b4e8212 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2073,7 +2073,6 @@ int qeth_send_control_data(struct qeth_card *card, int len,
 	spin_lock_irqsave(&card->lock, flags);
 	list_add_tail(&reply->list, &card->cmd_waiter_list);
 	spin_unlock_irqrestore(&card->lock, flags);
-	QETH_DBF_HEX(CTRL, 2, iob->data, QETH_DBF_CTRL_LEN);
 
 	while (atomic_cmpxchg(&card->write.irq_pending, 0, 1)) ;
 	qeth_prepare_control_data(card, len, iob);
-- 
2.13.5
