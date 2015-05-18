From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/8] qeth: fix handling of IPA return codes
Date: Mon, 18 May 2015 14:27:53 +0200
Message-ID: <1431952079-6847-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:39771 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153AbbERM2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 08:28:21 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 18 May 2015 13:28:19 +0100
In-Reply-To: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Function that executes IPA commands returns the result code from the
IPA response block. If non-negative, it needs to be transformed into
errno-compatible code before returning to the caller.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 0ea0869..1cdefae 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1808,10 +1808,9 @@ int qeth_bridgeport_query_ports(struct qeth_card *card,
 	cmd->data.sbp.hdr.seq_no = 1;
 	rc = qeth_send_ipa_cmd(card, iob, qeth_bridgeport_query_ports_cb,
 				(void *)&cbctl);
-	if (rc)
+	if (rc < 0)
 		return rc;
-	rc = qeth_bridgeport_makerc(card, &cbctl, IPA_SBP_QUERY_BRIDGE_PORTS);
-	return rc;
+	return qeth_bridgeport_makerc(card, &cbctl, IPA_SBP_QUERY_BRIDGE_PORTS);
 }
 EXPORT_SYMBOL_GPL(qeth_bridgeport_query_ports);
 
@@ -1874,10 +1873,9 @@ int qeth_bridgeport_setrole(struct qeth_card *card, enum qeth_sbp_roles role)
 	cmd->data.sbp.hdr.seq_no = 1;
 	rc = qeth_send_ipa_cmd(card, iob, qeth_bridgeport_set_cb,
 				(void *)&cbctl);
-	if (rc)
+	if (rc < 0)
 		return rc;
-	rc = qeth_bridgeport_makerc(card, &cbctl, setcmd);
-	return rc;
+	return qeth_bridgeport_makerc(card, &cbctl, setcmd);
 }
 
 /**
-- 
2.3.7
