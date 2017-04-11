From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 06/10] s390/qeth: use and remove some defines
Date: Tue, 11 Apr 2017 16:11:15 +0200
Message-ID: <20170411141119.82526-7-jwi@linux.vnet.ibm.com>
References: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:53111 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753293AbdDKOLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:11:45 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BE8xXU023417
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:45 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29rxeqfbyt-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:43 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 15:11:40 +0100
In-Reply-To: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. a buffer has 16 is_header flags, because that's its # of elements
2. replace the last occurrence of QETH_HEADER_SIZE, and remove it

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h    | 3 +--
 drivers/s390/net/qeth_l2_main.c | 2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index f575c7a566c8..760f752034e4 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -240,7 +240,6 @@ static inline int qeth_is_ipa_enabled(struct qeth_ipa_info *ipa,
 #define QETH_TX_TIMEOUT		100 * HZ
 #define QETH_RCD_TIMEOUT	60 * HZ
 #define QETH_RECLAIM_WORK_TIME	HZ
-#define QETH_HEADER_SIZE	32
 #define QETH_MAX_PORTNO		15
 
 /*IPv6 address autoconfiguration stuff*/
@@ -447,7 +446,7 @@ struct qeth_qdio_out_buffer {
 	atomic_t state;
 	int next_element_to_fill;
 	struct sk_buff_head skb_list;
-	int is_header[16];
+	int is_header[QDIO_MAX_ELEMENTS_PER_BUFFER];
 
 	struct qaob *aob;
 	struct qeth_qdio_out_q *q;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 11cf4a4b36a6..22f8eb007aa1 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -280,7 +280,7 @@ static void qeth_l2_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 	else
 		hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_UNICAST;
 
-	hdr->hdr.l2.pkt_length = skb->len-QETH_HEADER_SIZE;
+	hdr->hdr.l2.pkt_length = skb->len - sizeof(struct qeth_hdr);
 	/* VSWITCH relies on the VLAN
 	 * information to be present in
 	 * the QDIO header */
-- 
2.10.2
