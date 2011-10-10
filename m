From: Il Han <corone.il.han@gmail.com>
Subject: [PATCH] isdn: add missing cast operator in drivers/isdn/sc/init.c
Date: Mon, 10 Oct 2011 20:02:40 +0900
Message-ID: <1318244560-19213-1-git-send-email-corone.il.han@gmail.com>
Cc: netdev@vger.kernel.org, Il Han <corone.il.han@gmail.com>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:45936 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548Ab1JJLCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 07:02:55 -0400
Received: by ggnv2 with SMTP id v2so4345496ggn.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 04:02:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add (void __iomem *) to convert the value to the proper type before passing it to readl().

Signed-off-by: Il Han <corone.il.han@gmail.com>
---
 drivers/isdn/sc/init.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/sc/init.c b/drivers/isdn/sc/init.c
index ca710ab..79bde78 100644
--- a/drivers/isdn/sc/init.c
+++ b/drivers/isdn/sc/init.c
@@ -484,7 +484,7 @@ static int identify_board(unsigned long rambase, unsigned int iobase)
 	 */
 	outb(PRI_BASEPG_VAL, pgport);
 	msleep_interruptible(1000);
-	sig = readl(rambase + SIG_OFFSET);
+	sig = readl((void __iomem *)rambase + SIG_OFFSET);
 	pr_debug("Looking for a signature, got 0x%lx\n", sig);
 	if(sig == SIGNATURE)
 		return PRI_BOARD;
@@ -494,7 +494,7 @@ static int identify_board(unsigned long rambase, unsigned int iobase)
 	 */
 	outb(BRI_BASEPG_VAL, pgport);
 	msleep_interruptible(1000);
-	sig = readl(rambase + SIG_OFFSET);
+	sig = readl((void __iomem *)rambase + SIG_OFFSET);
 	pr_debug("Looking for a signature, got 0x%lx\n", sig);
 	if(sig == SIGNATURE)
 		return BRI_BOARD;
@@ -504,7 +504,7 @@ static int identify_board(unsigned long rambase, unsigned int iobase)
 	/*
 	 * Try to spot a card
 	 */
-	sig = readl(rambase + SIG_OFFSET);
+	sig = readl((void __iomem *)rambase + SIG_OFFSET);
 	pr_debug("Looking for a signature, got 0x%lx\n", sig);
 	if(sig != SIGNATURE)
 		return -1;
-- 
1.7.4.1
