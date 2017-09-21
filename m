From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 2/9] net/smc: add receive timeout check
Date: Thu, 21 Sep 2017 09:16:27 +0200
Message-ID: <20170921071634.16883-3-ubraun@linux.vnet.ibm.com>
References: <20170921071634.16883-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:41270 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751839AbdIUHQq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 03:16:46 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8L7FDrq079667
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:16:45 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d48cy1b7d-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:16:45 -0400
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 21 Sep 2017 08:16:43 +0100
In-Reply-To: <20170921071634.16883-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

The SMC receive function currently lacks a timeout check under the
condition that no data were received and no data are available. This
patch adds such a check.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/smc_rx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/smc/smc_rx.c b/net/smc/smc_rx.c
index b17a333e9bb0..3e631ae4b6b6 100644
--- a/net/smc/smc_rx.c
+++ b/net/smc/smc_rx.c
@@ -148,6 +148,8 @@ int smc_rx_recvmsg(struct smc_sock *smc, struct msghdr *msg, size_t len,
 				read_done = sock_intr_errno(timeo);
 				break;
 			}
+			if (!timeo)
+				return -EAGAIN;
 		}
 
 		if (!atomic_read(&conn->bytes_to_rcv)) {
-- 
2.13.5
