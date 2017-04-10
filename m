From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/10] net/smc: remove useless smc_ib_devices_list check
Date: Mon, 10 Apr 2017 14:57:57 +0200
Message-ID: <20170410125805.13653-3-ubraun@linux.vnet.ibm.com>
References: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:57642 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752877AbdDJM6Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:58:16 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ACs9FB126621
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:15 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29r9qva64y-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:15 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 10 Apr 2017 13:58:13 +0100
In-Reply-To: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The global event handler is created only, if the ib_device has already
been used by at least one link group. It is guaranteed that there exists
the corresponding entry in the smc_ib_devices list. Get rid of this
superfluous check.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 net/smc/smc_ib.c   | 2 --
 net/smc/smc_pnet.c | 2 +-
 net/smc/smc_pnet.h | 1 -
 3 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index e6743c0..b762577 100644
--- a/net/smc/smc_ib.c
+++ b/net/smc/smc_ib.c
@@ -179,8 +179,6 @@ static void smc_ib_global_event_handler(struct ib_event_handler *handler,
 	u8 port_idx;
 
 	smcibdev = container_of(handler, struct smc_ib_device, event_handler);
-	if (!smc_pnet_find_ib(smcibdev->ibdev->name))
-		return;
 
 	switch (ibevent->event) {
 	case IB_EVENT_PORT_ERR:
diff --git a/net/smc/smc_pnet.c b/net/smc/smc_pnet.c
index 9d3e7fb..f1cff01 100644
--- a/net/smc/smc_pnet.c
+++ b/net/smc/smc_pnet.c
@@ -219,7 +219,7 @@ static bool smc_pnetid_valid(const char *pnet_name, char *pnetid)
 }
 
 /* Find an infiniband device by a given name. The device might not exist. */
-struct smc_ib_device *smc_pnet_find_ib(char *ib_name)
+static struct smc_ib_device *smc_pnet_find_ib(char *ib_name)
 {
 	struct smc_ib_device *ibdev;
 
diff --git a/net/smc/smc_pnet.h b/net/smc/smc_pnet.h
index 32ab3df..c4f1bcc 100644
--- a/net/smc/smc_pnet.h
+++ b/net/smc/smc_pnet.h
@@ -16,7 +16,6 @@ struct smc_ib_device;
 int smc_pnet_init(void) __init;
 void smc_pnet_exit(void);
 int smc_pnet_remove_by_ibdev(struct smc_ib_device *ibdev);
-struct smc_ib_device *smc_pnet_find_ib(char *ib_name);
 void smc_pnet_find_roce_resource(struct sock *sk,
 				 struct smc_ib_device **smcibdev, u8 *ibport);
 
-- 
2.10.2
