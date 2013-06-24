From: frank.blaschka@de.ibm.com
Subject: [patch 3/5] qeth: change default standard blkt settings for OSA
Date: Mon, 24 Jun 2013 13:21:50 +0200
Message-ID: <20130624112226.650590209@de.ibm.com>
References: <20130624112147.347247916@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:36647 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473Ab3FXLWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 07:22:33 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Jun 2013 12:18:03 +0100
Content-Disposition: inline; filename=602-qeth-default-blkt.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

blkt settings (or LAN idle settings) for an OSA Express card
determine when and how often an OSA Express card tells the
operating system about new incoming packets. The semantic of
these settings has changed starting with OSA Express3. Currently
the qeth standard settings apply to OSA Express2 and older
generations of OSA Express cards, while new generations of OSA
Express cards require extra coding of their reasonable default.

To cover future OSA Express generations the qeth default standard
blkt setting is now the desired setting for OSA generations
starting with OSA Express3, while the fixed set of older OSA
Express cards receives its blkt settings explicitly.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Reviewed-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1729,14 +1729,14 @@ static void qeth_configure_blkt_default(
 	QETH_DBF_TEXT(SETUP, 2, "cfgblkt");
 
 	if (prcd[74] == 0xF0 && prcd[75] == 0xF0 &&
-	    (prcd[76] == 0xF5 || prcd[76] == 0xF6)) {
-		card->info.blkt.time_total = 250;
-		card->info.blkt.inter_packet = 5;
-		card->info.blkt.inter_packet_jumbo = 15;
-	} else {
+	    prcd[76] >= 0xF1 && prcd[76] <= 0xF4) {
 		card->info.blkt.time_total = 0;
 		card->info.blkt.inter_packet = 0;
 		card->info.blkt.inter_packet_jumbo = 0;
+	} else {
+		card->info.blkt.time_total = 250;
+		card->info.blkt.inter_packet = 5;
+		card->info.blkt.inter_packet_jumbo = 15;
 	}
 }
 
