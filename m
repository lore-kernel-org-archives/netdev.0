From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 25/28] mISDN: Bugfix hfcsusb: usb endpoint activation/deactivation
Date: Sat, 21 Apr 2012 18:09:23 +0200
Message-ID: <20120423170551.72ED49FB8D@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:57871 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447Ab2DWRI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Bachem <info@colognechip.com>

Fixed activation/deactivation of B1/B2's USB endpoints

Signed-off-by: Martin Bachem <info@colognechip.com>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfcsusb.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 3c20b4f..cd0f2f6 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -232,7 +232,7 @@ hfcusb_l2l1B(struct mISDNchannel *ch, struct sk_buff *skb)
 		return ret;
 	case PH_ACTIVATE_REQ:
 		if (!test_and_set_bit(FLG_ACTIVE, &bch->Flags)) {
-			hfcsusb_start_endpoint(hw, bch->nr);
+			hfcsusb_start_endpoint(hw, bch->nr - 1);
 			ret = hfcsusb_setup_bch(bch, ch->protocol);
 		} else
 			ret = 0;
@@ -496,12 +496,6 @@ open_bchannel(struct hfcsusb *hw, struct channel_req *rq)
 	bch->ch.protocol = rq->protocol;
 	rq->ch = &bch->ch;
 
-	/* start USB endpoint for bchannel */
-	if (rq->adr.channel  == 1)
-		hfcsusb_start_endpoint(hw, HFC_CHAN_B1);
-	else
-		hfcsusb_start_endpoint(hw, HFC_CHAN_B2);
-
 	if (!try_module_get(THIS_MODULE))
 		printk(KERN_WARNING "%s: %s:cannot get module\n",
 		       hw->name, __func__);
@@ -1806,7 +1800,7 @@ deactivate_bchannel(struct bchannel *bch)
 	mISDN_clear_bchannel(bch);
 	spin_unlock_irqrestore(&hw->lock, flags);
 	hfcsusb_setup_bch(bch, ISDN_P_NONE);
-	hfcsusb_stop_endpoint(hw, bch->nr);
+	hfcsusb_stop_endpoint(hw, bch->nr - 1);
 }
 
 /*
-- 
1.7.3.4
