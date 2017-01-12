From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 06/12] s390/qeth: drop qeth_l2_del_all_macs() parameter
Date: Thu, 12 Jan 2017 15:48:37 +0100
Message-ID: <20170112144843.33463-7-ubraun@linux.vnet.ibm.com>
References: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:39446 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750803AbdALOtV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:49:21 -0500
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CEn9H9033274
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:49:11 -0500
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27x9gwxcpt-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:49:09 -0500
Received: from localhost
        by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 14:48:57 -0000
In-Reply-To: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

The only caller passes del = 0, so remove both the parameter and
the code that handles != 0.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Acked-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 9c921c28..3025f56 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -216,7 +216,7 @@ static int qeth_l2_write_mac(struct qeth_card *card, struct qeth_mac *mac)
 	return rc;
 }
 
-static void qeth_l2_del_all_macs(struct qeth_card *card, int del)
+static void qeth_l2_del_all_macs(struct qeth_card *card)
 {
 	struct qeth_mac *mac;
 	struct hlist_node *tmp;
@@ -224,13 +224,6 @@ static void qeth_l2_del_all_macs(struct qeth_card *card, int del)
 
 	spin_lock_bh(&card->mclock);
 	hash_for_each_safe(card->mac_htable, i, tmp, mac, hnode) {
-		if (del) {
-			if (mac->is_uc)
-				qeth_l2_send_setdelmac(card, mac->mac_addr,
-						IPA_CMD_DELVMAC);
-			else
-				qeth_l2_send_delgroupmac(card, mac->mac_addr);
-		}
 		hash_del(&mac->hnode);
 		kfree(mac);
 	}
@@ -425,7 +418,7 @@ static void qeth_l2_stop_card(struct qeth_card *card, int recovery_mode)
 		card->state = CARD_STATE_SOFTSETUP;
 	}
 	if (card->state == CARD_STATE_SOFTSETUP) {
-		qeth_l2_del_all_macs(card, 0);
+		qeth_l2_del_all_macs(card);
 		qeth_clear_ipacmd_list(card);
 		card->state = CARD_STATE_HARDSETUP;
 	}
-- 
2.8.4
