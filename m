From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/10] net/smc: add receive timeout check
Date: Wed, 20 Sep 2017 13:58:05 +0200
Message-ID: <20170920115813.63745-3-ubraun@linux.vnet.ibm.com>
References: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57784 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751838AbdITL61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 07:58:27 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8KBw890092504
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:26 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d3p3gyh0q-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:58:26 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 20 Sep 2017 12:58:24 +0100
In-Reply-To: <20170920115813.63745-1-ubraun@linux.vnet.ibm.com>
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
