From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc9420: fix another postfixed timeout
Date: Mon, 16 Feb 2009 07:46:06 +0000
Message-ID: <1234770366-3572-1-git-send-email-steve.glendinning@smsc.com>
Cc: Roel Kluin <roel.kluin@gmail.com>,
	Vlad Lyalikov <vlad.lyalikov@smsc.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:43423 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753776AbZBPHpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 02:45:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin recently fixed several instances where variables reach -1,
but 0 is tested afterwards.  This patch fixes another, so the timeout
will be correctly detected and a warning printed.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc9420.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index a1e4b38..83938e1 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -341,7 +341,7 @@ static int smsc9420_eeprom_send_cmd(struct smsc9420_pdata *pd, u32 op)
 	do {
 		msleep(1);
 		e2cmd = smsc9420_reg_read(pd, E2P_CMD);
-	} while ((e2cmd & E2P_CMD_EPC_BUSY_) && (timeout--));
+	} while ((e2cmd & E2P_CMD_EPC_BUSY_) && (--timeout));
 
 	if (!timeout) {
 		smsc_info(HW, "TIMED OUT");
-- 
1.6.0.6

