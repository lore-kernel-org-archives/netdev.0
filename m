From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/3] qeth: Fix command sizes
Date: Fri, 27 Feb 2015 12:52:33 +0100
Message-ID: <1425037954-50840-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1425037954-50840-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:35187 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512AbbB0LxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 06:53:20 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 27 Feb 2015 11:53:19 -0000
In-Reply-To: <1425037954-50840-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

This patch adjusts two instances where we were using the (too big)
struct qeth_ipacmd_setadpparms size instead of the commands' actual
size. This didn't do any harm, but wasted a few bytes.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 642c77c..3466d3c 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4218,7 +4218,7 @@ void qeth_setadp_promisc_mode(struct qeth_card *card)
 	QETH_CARD_TEXT_(card, 4, "mode:%x", mode);
 
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_SET_PROMISC_MODE,
-			sizeof(struct qeth_ipacmd_setadpparms));
+			sizeof(struct qeth_ipacmd_setadpparms_hdr) + 8);
 	if (!iob)
 		return;
 	cmd = (struct qeth_ipa_cmd *)(iob->data + IPA_PDU_HEADER_SIZE);
@@ -4290,7 +4290,8 @@ int qeth_setadpparms_change_macaddr(struct qeth_card *card)
 	QETH_CARD_TEXT(card, 4, "chgmac");
 
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_ALTER_MAC_ADDRESS,
-				   sizeof(struct qeth_ipacmd_setadpparms));
+				   sizeof(struct qeth_ipacmd_setadpparms_hdr) +
+				   sizeof(struct qeth_change_addr));
 	if (!iob)
 		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-- 
2.1.4
