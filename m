From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/10] s390/qeth: remove unimplemented gdev routines
Date: Tue, 11 Apr 2017 16:11:19 +0200
Message-ID: <20170411141119.82526-11-jwi@linux.vnet.ibm.com>
References: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46046 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753441AbdDKOLx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:11:53 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BE8k0O100664
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:47 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29rpfhk245-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:47 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 15:11:45 +0100
In-Reply-To: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

prepare() and complete() are not implemented by any discipline, so just
drop all the indirection.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  2 --
 drivers/s390/net/qeth_core_main.c | 19 ++-----------------
 2 files changed, 2 insertions(+), 19 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index a634ec2a08f3..f6aa21176d89 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -710,8 +710,6 @@ struct qeth_discipline {
 	void (*remove) (struct ccwgroup_device *);
 	int (*set_online) (struct ccwgroup_device *);
 	int (*set_offline) (struct ccwgroup_device *);
-	int (*prepare) (struct ccwgroup_device *);
-	void (*complete) (struct ccwgroup_device *);
 	int (*freeze)(struct ccwgroup_device *);
 	int (*thaw) (struct ccwgroup_device *);
 	int (*restore)(struct ccwgroup_device *);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 88f4c6cff9a4..38114a8d56e0 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5756,21 +5756,6 @@ static void qeth_core_shutdown(struct ccwgroup_device *gdev)
 	qdio_free(CARD_DDEV(card));
 }
 
-static int qeth_core_prepare(struct ccwgroup_device *gdev)
-{
-	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
-	if (card->discipline && card->discipline->prepare)
-		return card->discipline->prepare(gdev);
-	return 0;
-}
-
-static void qeth_core_complete(struct ccwgroup_device *gdev)
-{
-	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
-	if (card->discipline && card->discipline->complete)
-		card->discipline->complete(gdev);
-}
-
 static int qeth_core_freeze(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
@@ -5805,8 +5790,8 @@ static struct ccwgroup_driver qeth_core_ccwgroup_driver = {
 	.set_online = qeth_core_set_online,
 	.set_offline = qeth_core_set_offline,
 	.shutdown = qeth_core_shutdown,
-	.prepare = qeth_core_prepare,
-	.complete = qeth_core_complete,
+	.prepare = NULL,
+	.complete = NULL,
 	.freeze = qeth_core_freeze,
 	.thaw = qeth_core_thaw,
 	.restore = qeth_core_restore,
-- 
2.10.2
