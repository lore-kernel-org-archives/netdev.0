From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/2] net/iucv: improve endianness handling
Date: Fri, 23 Jun 2017 19:32:27 +0200
Message-ID: <20170623173228.70128-2-jwi@linux.vnet.ibm.com>
References: <20170623173228.70128-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42623 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754345AbdFWRcn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 13:32:43 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5NHUQ8s119085
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 13:32:42 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b8yueenug-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 13:32:42 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Fri, 23 Jun 2017 18:32:39 +0100
In-Reply-To: <20170623173228.70128-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

Use proper endianness conversion for an skb protocol assignment. Given
that IUCV is only available on big endian systems (s390), this simply
avoids an endianness warning reported by sparse.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 2cf9d59f1b72..05112094d76b 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -362,7 +362,7 @@ static int afiucv_hs_send(struct iucv_message *imsg, struct sock *sock,
 		else
 			skb_trim(skb, skb->dev->mtu);
 	}
-	skb->protocol = ETH_P_AF_IUCV;
+	skb->protocol = cpu_to_be16(ETH_P_AF_IUCV);
 	nskb = skb_clone(skb, GFP_ATOMIC);
 	if (!nskb)
 		return -ENOMEM;
-- 
2.11.2
