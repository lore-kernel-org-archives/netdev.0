From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 1/8] s390: print correct level for HiperSockets devices
Date: Wed, 20 Jun 2007 12:55:18 +0200
Message-ID: <20070620105518.GA9454@de.ibm.com>
References: <20070620104817.GA2627@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:58177 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126AbXFTKxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 06:53:46 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5K9ohMI013864
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 05:50:43 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KAri3d558058
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:53:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KAriZt018413
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:53:44 -0400
Content-Disposition: inline
In-Reply-To: <20070620104817.GA2627@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

For real HiperSockets the EBCDIC-ASCII conversion is not necessary.
This is only needed for z/VM GuestLAN devices.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/qeth_main.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 0b96d49..ea2fd98 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -7797,15 +7797,17 @@ qeth_print_status_message(struct qeth_card *card)
 		}
 		/* fallthrough */
 	case QETH_CARD_TYPE_IQD:
-		card->info.mcl_level[0] = (char) _ebcasc[(__u8)
-			card->info.mcl_level[0]];
-		card->info.mcl_level[1] = (char) _ebcasc[(__u8)
-			card->info.mcl_level[1]];
-		card->info.mcl_level[2] = (char) _ebcasc[(__u8)
-			card->info.mcl_level[2]];
-		card->info.mcl_level[3] = (char) _ebcasc[(__u8)
-			card->info.mcl_level[3]];
-		card->info.mcl_level[QETH_MCL_LENGTH] = 0;
+		if (card->info.guestlan) {
+			card->info.mcl_level[0] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[0]];
+			card->info.mcl_level[1] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[1]];
+			card->info.mcl_level[2] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[2]];
+			card->info.mcl_level[3] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[3]];
+			card->info.mcl_level[QETH_MCL_LENGTH] = 0;
+		}
 		break;
 	default:
 		memset(&card->info.mcl_level[0], 0, QETH_MCL_LENGTH + 1);
-- 
1.5.2.1

