From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 04/12] s390/qeth: Allow reading hsuid in state DOWN
Date: Thu, 12 Jan 2017 15:48:35 +0100
Message-ID: <20170112144843.33463-5-ubraun@linux.vnet.ibm.com>
References: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:34942 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750742AbdALOtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:49:06 -0500
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CEmnqa082538
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:48:56 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27xaguuqu1-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:48:56 -0500
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 14:48:54 -0000
In-Reply-To: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

Accessing the current hsuid via card->options.hsuid is perfectly
fine, even when the card is DOWN.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_sys.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index 0e00a5c..3cd4d9f 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -250,9 +250,6 @@ static ssize_t qeth_l3_dev_hsuid_show(struct device *dev,
 	if (card->info.type != QETH_CARD_TYPE_IQD)
 		return -EPERM;
 
-	if (card->state == CARD_STATE_DOWN)
-		return -EPERM;
-
 	memcpy(tmp_hsuid, card->options.hsuid, sizeof(tmp_hsuid));
 	EBCASC(tmp_hsuid, 8);
 	return sprintf(buf, "%s\n", tmp_hsuid);
-- 
2.8.4
