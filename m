From: frank.blaschka@de.ibm.com
Subject: [patch 2/3] qeth: remove unused variable
Date: Mon, 22 Apr 2013 13:12:28 +0200
Message-ID: <20130422111238.384255732@de.ibm.com>
References: <20130422111226.882214164@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:47812 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570Ab3DVLMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 07:12:44 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 22 Apr 2013 12:09:36 +0100
Content-Disposition: inline; filename=601-qeth-unused-variable.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

remove unused variable

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |    2 +-
 drivers/s390/net/qeth_core_main.c |    2 +-
 drivers/s390/net/qeth_l2_main.c   |    3 +--
 drivers/s390/net/qeth_l3_main.c   |    3 +--
 4 files changed, 4 insertions(+), 6 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -915,7 +915,7 @@ int qeth_send_control_data(struct qeth_c
 	int (*reply_cb)(struct qeth_card *, struct qeth_reply*, unsigned long),
 	void *reply_param);
 int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
-int qeth_get_elements_no(struct qeth_card *, void *, struct sk_buff *, int);
+int qeth_get_elements_no(struct qeth_card *, struct sk_buff *, int);
 int qeth_get_elements_for_frags(struct sk_buff *);
 int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
 			struct sk_buff *, struct qeth_hdr *, int, int, int);
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3698,7 +3698,7 @@ int qeth_get_elements_for_frags(struct s
 }
 EXPORT_SYMBOL_GPL(qeth_get_elements_for_frags);
 
-int qeth_get_elements_no(struct qeth_card *card, void *hdr,
+int qeth_get_elements_no(struct qeth_card *card,
 		     struct sk_buff *skb, int elems)
 {
 	int dlen = skb->len - skb->data_len;
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -773,8 +773,7 @@ static int qeth_l2_hard_start_xmit(struc
 		}
 	}
 
-	elements = qeth_get_elements_no(card, (void *)hdr, new_skb,
-						elements_needed);
+	elements = qeth_get_elements_no(card, new_skb, elements_needed);
 	if (!elements) {
 		if (data_offset >= 0)
 			kmem_cache_free(qeth_core_header_cache, hdr);
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3037,8 +3037,7 @@ static int qeth_l3_hard_start_xmit(struc
 			qeth_l3_hdr_csum(card, hdr, new_skb);
 	}
 
-	elems = qeth_get_elements_no(card, (void *)hdr, new_skb,
-						 elements_needed);
+	elems = qeth_get_elements_no(card, new_skb, elements_needed);
 	if (!elems) {
 		if (data_offset >= 0)
 			kmem_cache_free(qeth_core_header_cache, hdr);
