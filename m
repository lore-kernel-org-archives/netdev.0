From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 9/9] s390/qeth: tidy up parameter naming for qeth_do_send_packet()
Date: Mon, 18 Sep 2017 21:18:22 +0200
Message-ID: <20170918191822.65142-10-jwi@linux.vnet.ibm.com>
References: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54654 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751301AbdIRTTe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:19:34 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8IJJFL5104970
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:19:34 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d2m1r0k5w-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:19:34 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 18 Sep 2017 20:19:31 +0100
In-Reply-To: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Remus <jremus@linux.vnet.ibm.com>

Cppcheck reports the following for drivers/s390/net/qeth_core.h:

    warning - line 1560 - Function 'qeth_do_send_packet' argument order
    different:
    declaration 'card, queue, skb, hdr, hd_len, offset, elements'
    definition  'card, queue, skb, hdr, offset, hd_len, elements_needed'.

Match the naming in the function's declaration against its definition.

Signed-off-by: Jens Remus <jremus@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index b7e8531625aa..91fcadbede80 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -967,7 +967,8 @@ int qeth_do_send_packet_fast(struct qeth_qdio_out_q *queue, struct sk_buff *skb,
 			     unsigned int hd_len);
 int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 			struct sk_buff *skb, struct qeth_hdr *hdr,
-			unsigned int hd_len, unsigned int offset, int elements);
+			unsigned int offset, unsigned int hd_len,
+			int elements_needed);
 int qeth_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 int qeth_core_get_sset_count(struct net_device *, int);
 void qeth_core_get_ethtool_stats(struct net_device *,
-- 
2.13.5
