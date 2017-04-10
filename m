From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 08/10] net/smc: remove duplicate unhash
Date: Mon, 10 Apr 2017 14:58:03 +0200
Message-ID: <20170410125805.13653-9-ubraun@linux.vnet.ibm.com>
References: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:35073 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753239AbdDJM60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:58:26 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ACsKto058391
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:25 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29r8u8vc6p-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:25 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 10 Apr 2017 13:58:23 +0100
In-Reply-To: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unhash is already called in sock_put_work. Remove the second call.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 net/smc/af_smc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 3b7eda6..491a8b2 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -147,7 +147,6 @@ static int smc_release(struct socket *sock)
 		schedule_delayed_work(&smc->sock_put_work,
 				      SMC_CLOSE_SOCK_PUT_DELAY);
 	}
-	sk->sk_prot->unhash(sk);
 	release_sock(sk);
 
 	sock_put(sk);
-- 
2.10.2
