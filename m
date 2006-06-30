From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/5] tg3: Turn on hw fix for ASF problems
Date: Thu, 29 Jun 2006 18:29:19 -0700
Message-ID: <1151630959.21798.19.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:12037 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1750753AbWF3B2J
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 21:28:09 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clear a bit to enable a hardware fix for some ASF related problem.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c32655c..2c36e70 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6157,8 +6157,12 @@ static int tg3_reset_hw(struct tg3 *tp, 
 #endif
 
 	/* Receive/send statistics. */
-	if ((rdmac_mode & RDMAC_MODE_FIFO_SIZE_128) &&
-	    (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)) {
+	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
+		val = tr32(RCVLPC_STATS_ENABLE);
+		val &= ~RCVLPC_STATSENAB_DACK_FIX;
+		tw32(RCVLPC_STATS_ENABLE, val);
+	} else if ((rdmac_mode & RDMAC_MODE_FIFO_SIZE_128) &&
+		   (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)) {
 		val = tr32(RCVLPC_STATS_ENABLE);
 		val &= ~RCVLPC_STATSENAB_LNGBRST_RFIX;
 		tw32(RCVLPC_STATS_ENABLE, val);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index e9177f8..97a8604 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -760,6 +760,7 @@
 #define  RCVLPC_STATSCTRL_ENABLE	 0x00000001
 #define  RCVLPC_STATSCTRL_FASTUPD	 0x00000002
 #define RCVLPC_STATS_ENABLE		0x00002018
+#define  RCVLPC_STATSENAB_DACK_FIX	 0x00040000
 #define  RCVLPC_STATSENAB_LNGBRST_RFIX	 0x00400000
 #define RCVLPC_STATS_INCMASK		0x0000201c
 /* 0x2020 --> 0x2100 unused */


