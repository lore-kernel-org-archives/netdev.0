From: Alejandro Martinez Ruiz <alex@flawedcode.org>
Subject: [PATCH 3/3] sk98lin: kill bogus check and convert to use
	ARRAY_SIZE()
Date: Thu, 18 Oct 2007 11:51:42 +0200
Message-ID: <20071018095142.GD23058@inspiron>
References: <20071018094706.GA23058@inspiron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:20565 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755687AbXJRJs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 05:48:28 -0400
Received: by ug-out-1314.google.com with SMTP id z38so396998ugc
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2007 02:48:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20071018094706.GA23058@inspiron>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Alejandro Martinez Ruiz <alex@flawedcode.org>
Date: Thu, 18 Oct 2007 10:22:02 +0200
Subject: [PATCH] sk98lin: kill bogus check and convert to use ARRAY_SIZE()

This converts uses of ARRAY_SIZE(), and while at it also kills
unreachable code as far as I can say. I can't tell what was the author
trying to do with the following check. First we have:

PNMI_STATIC const SK_PNMI_STATADDR
		StatAddr[SK_PNMI_MAX_IDX][SK_PNMI_MAC_TYPES];

and then a check goes like this:

if (SK_PNMI_MAX_IDX !=
   (sizeof(StatAddr) / (sizeof(SK_PNMI_STATADDR) * SK_PNMI_MAC_TYPES)))

with the second line being just ARRAY_SIZE(StatAddr), which will always
return SK_PNMI_MAX_IDX, rendering the check useless.

Signed-off-by: Alejandro Martinez Ruiz <alex@flawedcode.org>
---
 drivers/net/sk98lin/skgemib.c  |    2 +-
 drivers/net/sk98lin/skgepnmi.c |   12 ------------
 drivers/net/sk98lin/skgesirq.c |    2 +-
 3 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/sk98lin/skgemib.c b/drivers/net/sk98lin/skgemib.c
index 0a6f67a..fde4508 100644
--- a/drivers/net/sk98lin/skgemib.c
+++ b/drivers/net/sk98lin/skgemib.c
@@ -82,7 +82,7 @@ PNMI_STATIC int DiagActions(SK_AC *pAC, SK_IOC IoC, int action, SK_U32 Id,
 
 
 /* defines *******************************************************************/
-#define ID_TABLE_SIZE (sizeof(IdTable)/sizeof(IdTable[0]))
+#define ID_TABLE_SIZE	ARRAY_SIZE(IdTable)
 
 
 /* global variables **********************************************************/
diff --git a/drivers/net/sk98lin/skgepnmi.c b/drivers/net/sk98lin/skgepnmi.c
index b36dd9a..3c19d98 100644
--- a/drivers/net/sk98lin/skgepnmi.c
+++ b/drivers/net/sk98lin/skgepnmi.c
@@ -388,18 +388,6 @@ int Level)		/* Initialization level */
 						SK_PNMI_CNT_NO, SK_PNMI_MAX_IDX));
 		}
 
-		if (SK_PNMI_MAX_IDX !=
-			(sizeof(StatAddr) / (sizeof(SK_PNMI_STATADDR) * SK_PNMI_MAC_TYPES))) {
-			
-			SK_ERR_LOG(pAC, SK_ERRCL_SW, SK_PNMI_ERR050, SK_PNMI_ERR050MSG);
-
-			SK_DBG_MSG(pAC, SK_DBGMOD_PNMI, SK_DBGCAT_INIT | SK_DBGCAT_FATAL,
-					   ("StatAddr table size (%d) differs from "
-						"SK_PNMI_MAX_IDX (%d)\n",
-						(sizeof(StatAddr) /
-						 (sizeof(SK_PNMI_STATADDR) * SK_PNMI_MAC_TYPES)),
-						 SK_PNMI_MAX_IDX));
-		}
 #endif /* SK_PNMI_CHECK */
 		break;
 
diff --git a/drivers/net/sk98lin/skgesirq.c b/drivers/net/sk98lin/skgesirq.c
index 3e7aa49..e5ee6d6 100644
--- a/drivers/net/sk98lin/skgesirq.c
+++ b/drivers/net/sk98lin/skgesirq.c
@@ -892,7 +892,7 @@ int		Port)		/* Which port should be checked */
 	 */
 	RxCts = 0;
 
-	for (i = 0; i < sizeof(SkGeRxRegs)/sizeof(SkGeRxRegs[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(SkGeRxRegs); i++) {
 		
 		(void)SkXmMacStatistic(pAC, IoC, Port, SkGeRxRegs[i], &RxTmp);
 		
-- 
1.5.3.4


