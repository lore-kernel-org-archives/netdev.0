From: frank.blaschka@de.ibm.com
Subject: [patch 2/2] [PATCH] qeth: Use blkt defaults for OSA Express 4
Date: Mon, 23 Apr 2012 09:21:42 +0200
Message-ID: <20120423072158.645482656@de.ibm.com>
References: <20120423072140.297458261@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:41652 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790Ab2DWHWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 03:22:03 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 23 Apr 2012 08:22:02 +0100
Content-Disposition: inline; filename=601-qeth-blkt-defaults.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

The previous blkt defaults for OSA Express 4 cards produced inadequate
performance for streaming workloads. The present patch will apply a
set of more appropriate defaults.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1672,7 +1672,8 @@ static void qeth_configure_blkt_default(
 {
 	QETH_DBF_TEXT(SETUP, 2, "cfgblkt");
 
-	if (prcd[74] == 0xF0 && prcd[75] == 0xF0 && prcd[76] == 0xF5) {
+	if (prcd[74] == 0xF0 && prcd[75] == 0xF0 &&
+	    (prcd[76] == 0xF5 || prcd[76] == 0xF6)) {
 		card->info.blkt.time_total = 250;
 		card->info.blkt.inter_packet = 5;
 		card->info.blkt.inter_packet_jumbo = 15;
