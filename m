From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 04/10] s390/qeth: remove unused parameter
Date: Tue, 11 Apr 2017 16:11:13 +0200
Message-ID: <20170411141119.82526-5-jwi@linux.vnet.ibm.com>
References: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:33998 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753465AbdDKOLv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:11:51 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BE8vQB089306
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:41 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29rh6yxhpr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:40 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 15:11:36 +0100
In-Reply-To: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'elements_needed' is not used in qeth_do_send_packet_fast(),
so consequently remove it.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      | 2 +-
 drivers/s390/net/qeth_core_main.c | 3 +--
 drivers/s390/net/qeth_l2_main.c   | 2 +-
 drivers/s390/net/qeth_l3_main.c   | 2 +-
 4 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index cc1a4baeba55..f575c7a566c8 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -949,7 +949,7 @@ int qeth_get_elements_no(struct qeth_card *card, struct sk_buff *skb,
 			 int extra_elems, int data_offset);
 int qeth_get_elements_for_frags(struct sk_buff *);
 int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
-			struct sk_buff *, struct qeth_hdr *, int, int, int);
+			struct sk_buff *, struct qeth_hdr *, int, int);
 int qeth_do_send_packet(struct qeth_card *, struct qeth_qdio_out_q *,
 		    struct sk_buff *, struct qeth_hdr *, int);
 int qeth_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index cf5493e525e8..44d15c967c7d 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4024,8 +4024,7 @@ static inline int qeth_fill_buffer(struct qeth_qdio_out_q *queue,
 
 int qeth_do_send_packet_fast(struct qeth_card *card,
 		struct qeth_qdio_out_q *queue, struct sk_buff *skb,
-		struct qeth_hdr *hdr, int elements_needed,
-		int offset, int hd_len)
+		struct qeth_hdr *hdr, int offset, int hd_len)
 {
 	struct qeth_qdio_out_buffer *buffer;
 	int index;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 2ad378b57f9f..ab0d065a9ba2 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -783,7 +783,7 @@ static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 					 elements);
 	} else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
-					elements, data_offset, hd_len);
+					      data_offset, hd_len);
 	if (!rc) {
 		card->stats.tx_packets++;
 		card->stats.tx_bytes += tx_bytes;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index ca21a2065a5d..7d902b93fd5a 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2810,7 +2810,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr, elements);
 	} else
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
-					elements, data_offset, 0);
+					      data_offset, 0);
 
 	if (!rc) {
 		card->stats.tx_packets++;
-- 
2.10.2
