From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 7/7] s390/netiucv: improve endianness handling
Date: Wed,  5 Apr 2017 10:40:15 +0200
Message-ID: <20170405084015.35772-8-ubraun@linux.vnet.ibm.com>
References: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45107 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754614AbdDEIkm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 04:40:42 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v358d8tf033132
        for <netdev@vger.kernel.org>; Wed, 5 Apr 2017 04:40:41 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29mv9xthy3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 04:40:41 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 5 Apr 2017 09:40:40 +0100
In-Reply-To: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

Replace ntohs with endianness conversion for the SKB protocol assignment
to avoid an endianness warning reported by sparse. No functional change.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/netiucv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 3f85b97..dba94b4 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -635,7 +635,7 @@ static void netiucv_unpack_skb(struct iucv_connection *conn,
 	skb_put(pskb, NETIUCV_HDRLEN);
 	pskb->dev = dev;
 	pskb->ip_summed = CHECKSUM_NONE;
-	pskb->protocol = ntohs(ETH_P_IP);
+	pskb->protocol = cpu_to_be16(ETH_P_IP);
 
 	while (1) {
 		struct sk_buff *skb;
-- 
2.10.2
