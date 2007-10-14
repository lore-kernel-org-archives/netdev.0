From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] TC35815: Fix build
Date: Sun, 14 Oct 2007 14:40:26 +0100
Message-ID: <20071014134026.GA30056@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:37691 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757723AbXJOKZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 06:25:46 -0400
Received: from localhost.localdomain ([127.0.0.1]:22219 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20034796AbXJOKZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 11:25:45 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bea3348eef27e6044b6161fd04c3152215f96411 broke the build of tc35815.c
for the non-NAPI case:

  CC      drivers/net/tc35815.o
drivers/net/tc35815.c: In function 'tc35815_interrupt':
drivers/net/tc35815.c:1464: error: redefinition of 'lp'
drivers/net/tc35815.c:1443: error: previous definition of 'lp' was here

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index a679f43..8038f28 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1461,7 +1461,6 @@ static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
 	}
 	return IRQ_NONE;
 #else
-	struct tc35815_local *lp = dev->priv;
 	int handled;
 	u32 status;
 
