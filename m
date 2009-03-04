From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/2] smsc911x: check for FFWD success before checking for timeout
Date: Wed,  4 Mar 2009 17:33:24 +0000
Message-ID: <1236188005-14065-1-git-send-email-steve.glendinning@smsc.com>
Cc: Roel Kluin <roel.kluin@gmail.com>,
	Juha Leppanen <juha_motorsportcom@luukku.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.240.115]:37261 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751845AbZCDRd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 12:33:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch from Juha Leppanen suppresses a false warning if a fast
forward operation succeeds on the very last attempt.

Juha> If smsc911x_reg_read loop is executed 500 times, timeout reaches 0
Juha> and the 500th smsc911x_reg_read result in val is ignored. If
Juha> testing order is changed, then val is checked first. The 500th
Juha> reg_read might be GOOD, why ignore it!

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index dceae8a..9a79510 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -955,7 +955,7 @@ smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int pktbytes)
 		do {
 			udelay(1);
 			val = smsc911x_reg_read(pdata, RX_DP_CTRL);
-		} while (--timeout && (val & RX_DP_CTRL_RX_FFWD_));
+		} while ((val & RX_DP_CTRL_RX_FFWD_) && --timeout);
 
 		if (unlikely(timeout == 0))
 			SMSC_WARNING(HW, "Timed out waiting for "
-- 
1.6.0.6

