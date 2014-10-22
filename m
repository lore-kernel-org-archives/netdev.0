From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH 2/6] qeth: fix some trace formating issues
Date: Wed, 22 Oct 2014 12:18:03 +0200
Message-ID: <1413973087-18740-3-git-send-email-blaschka@linux.vnet.ibm.com>
References: <1413973087-18740-1-git-send-email-blaschka@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:55238 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755099AbaJVKSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 06:18:16 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 11:18:15 +0100
In-Reply-To: <1413973087-18740-1-git-send-email-blaschka@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

This patch fixes trace formatting issues using the
QETH_CARD_TEXT_ macro. The total size of each trace entry
is 8 bytes. Some of the sprintf formats exceed these 8
bytes (for example using abcd:%d and the converted value
needs more than 3 bytes). The solution is to shorten the
text prepending the value or use a different format (%x).

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 6 +++---
 drivers/s390/net/qeth_l2_main.c   | 2 +-
 drivers/s390/net/qeth_l3_main.c   | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 098bb0f..f407e37 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4134,7 +4134,7 @@ static int qeth_setadp_promisc_mode_cb(struct qeth_card *card,
 
 	qeth_default_setadapterparms_cb(card, reply, (unsigned long)cmd);
 	if (cmd->hdr.return_code) {
-		QETH_CARD_TEXT_(card, 4, "prmrc%2.2x", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 4, "prmrc%x", cmd->hdr.return_code);
 		setparms->data.mode = SET_PROMISC_MODE_OFF;
 	}
 	card->info.promisc_mode = setparms->data.mode;
@@ -4501,13 +4501,13 @@ static int qeth_snmp_command_cb(struct qeth_card *card,
 	snmp = &cmd->data.setadapterparms.data.snmp;
 
 	if (cmd->hdr.return_code) {
-		QETH_CARD_TEXT_(card, 4, "scer1%i", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 4, "scer1%x", cmd->hdr.return_code);
 		return 0;
 	}
 	if (cmd->data.setadapterparms.hdr.return_code) {
 		cmd->hdr.return_code =
 			cmd->data.setadapterparms.hdr.return_code;
-		QETH_CARD_TEXT_(card, 4, "scer2%i", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 4, "scer2%x", cmd->hdr.return_code);
 		return 0;
 	}
 	data_len = *((__u16 *)QETH_IPA_PDU_LEN_PDU1(data));
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index c2679bf..d02cd1a 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1512,7 +1512,7 @@ static void qeth_bridge_state_change(struct qeth_card *card,
 
 	QETH_CARD_TEXT(card, 2, "brstchng");
 	if (qports->entry_length != sizeof(struct qeth_sbp_port_entry)) {
-		QETH_CARD_TEXT_(card, 2, "BPsz%.8d", qports->entry_length);
+		QETH_CARD_TEXT_(card, 2, "BPsz%04x", qports->entry_length);
 		return;
 	}
 	extrasize = sizeof(struct qeth_sbp_port_entry) * qports->num_entries;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index afebb97..857a990 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2502,7 +2502,7 @@ static int qeth_l3_arp_query(struct qeth_card *card, char __user *udata)
 			rc = -EFAULT;
 			goto free_and_out;
 		}
-		QETH_CARD_TEXT_(card, 4, "qacts");
+		QETH_CARD_TEXT(card, 4, "qacts");
 	}
 free_and_out:
 	kfree(qinfo.udata);
-- 
1.8.5.5
