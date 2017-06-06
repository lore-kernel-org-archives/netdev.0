From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/9] s390/qeth: query IPv6 IPA support on HiperSockets
Date: Tue,  6 Jun 2017 14:33:44 +0200
Message-ID: <20170606123350.13781-4-jwi@linux.vnet.ibm.com>
References: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52373 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751430AbdFFMeE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:34:04 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v56CXoKD070781
        for <netdev@vger.kernel.org>; Tue, 6 Jun 2017 08:34:03 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2awveg88ef-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:34:03 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 6 Jun 2017 13:34:00 +0100
In-Reply-To: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HiperSocket devices don't need the full IPv6 initialization, but we
should still query the supported assists for logging purposes.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 56e813972d77..fb4eee2a46ee 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1035,9 +1035,6 @@ static int qeth_l3_softsetup_ipv6(struct qeth_card *card)
 
 	QETH_CARD_TEXT(card, 3, "softipv6");
 
-	if (card->info.type == QETH_CARD_TYPE_IQD)
-		goto out;
-
 	rc = qeth_query_ipassists(card, QETH_PROT_IPV6);
 	if (rc) {
 		dev_err(&card->gdev->dev,
@@ -1045,6 +1042,10 @@ static int qeth_l3_softsetup_ipv6(struct qeth_card *card)
 			QETH_CARD_IFNAME(card));
 		return rc;
 	}
+
+	if (card->info.type == QETH_CARD_TYPE_IQD)
+		goto out;
+
 	rc = qeth_send_simple_setassparms(card, IPA_IPV6,
 					  IPA_CMD_ASS_START, 3);
 	if (rc) {
-- 
2.11.2
