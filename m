From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 4/9] s390/qeth: log bridgeport capabilities
Date: Tue,  6 Jun 2017 14:33:45 +0200
Message-ID: <20170606123350.13781-5-jwi@linux.vnet.ibm.com>
References: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:60963 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751489AbdFFMeK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:34:10 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v56CXfZH008561
        for <netdev@vger.kernel.org>; Tue, 6 Jun 2017 08:34:04 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2awuyka9rp-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:34:03 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 6 Jun 2017 13:34:02 +0100
In-Reply-To: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridgeport is a l2-specific feature, and we should write its
capabilities to a debug entry.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index bd2df62a5cdf..70b633f951ea 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1017,6 +1017,13 @@ static int qeth_l2_start_ipassists(struct qeth_card *card)
 	return 0;
 }
 
+static void qeth_l2_trace_features(struct qeth_card *card)
+{
+	QETH_CARD_TEXT(card, 2, "l2featur");
+	QETH_CARD_HEX(card, 2, &card->options.sbp.supported_funcs,
+		      sizeof(card->options.sbp.supported_funcs));
+}
+
 static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
@@ -1040,6 +1047,7 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 		dev_info(&card->gdev->dev,
 		"The device represents a Bridge Capable Port\n");
 	qeth_trace_features(card);
+	qeth_l2_trace_features(card);
 
 	if (!card->dev && qeth_l2_setup_netdev(card)) {
 		rc = -ENODEV;
-- 
2.11.2
