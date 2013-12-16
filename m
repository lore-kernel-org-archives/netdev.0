From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] netiucv: improve state checking in conn_action_txdone
Date: Mon, 16 Dec 2013 09:44:51 +0100
Message-ID: <20131216084516.005987003@de.ibm.com>
References: <20131216084450.304555472@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:43211 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680Ab3LPIpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 03:45:21 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 16 Dec 2013 08:45:19 -0000
Content-Disposition: inline; filename=600-netiucv-smatch.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

state checking in conn_action_txdone() is inconsistent.
This patch makes it consistent and issues a trace message
if an unexpected state is detected for the netiucv device.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/netiucv.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -739,8 +739,12 @@ static void conn_action_txdone(fsm_insta
 
 	IUCV_DBF_TEXT(trace, 4, __func__);
 
-	if (conn && conn->netdev)
-		privptr = netdev_priv(conn->netdev);
+	if (!conn || !conn->netdev) {
+		IUCV_DBF_TEXT(data, 2,
+			      "Send confirmation for unlinked connection\n");
+		return;
+	}
+	privptr = netdev_priv(conn->netdev);
 	conn->prof.tx_pending--;
 	if (single_flag) {
 		if ((skb = skb_dequeue(&conn->commit_queue))) {
