From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 28/28] mISDN: Remove additonal PH_DATA confirm for raw data
Date: Sat, 21 Apr 2012 18:27:43 +0200
Message-ID: <20120423170551.CEE189FB80@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:63686 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299Ab2DWRIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the confirm is already done in get_next_bframe to
allow early delivery of the next data from higher layers.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 50d10ea..7662148 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -2180,10 +2180,6 @@ next_frame:
 		HFC_wait_nodebug(hc);
 	}
 
-	/* send confirm, since get_net_bframe will not do it with trans */
-	if (bch && test_bit(FLG_TRANSPARENT, &bch->Flags))
-		confirm_Bsend(bch);
-
 	/* check for next frame */
 	dev_kfree_skb(*sp);
 	if (bch && get_next_bframe(bch)) { /* hdlc is confirmed here */
-- 
1.7.3.4
