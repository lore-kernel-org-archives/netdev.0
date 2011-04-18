From: David Miller <davem@davemloft.net>
Subject: [PATCH 17/42] isdn: hfcsusb: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:25 -0700 (PDT)
Message-ID: <20110417.173325.70190780.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51036
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753846Ab1DRAd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:59 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3B72224C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'buf' is set but unused in
ctrl_complete().  Just kill it off.

Similarly for the variable 'err' in setup_hfcsusb().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hardware/mISDN/hfcsusb.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 8700474..3ccbff1 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -118,14 +118,12 @@ static void
 ctrl_complete(struct urb *urb)
 {
 	struct hfcsusb *hw = (struct hfcsusb *) urb->context;
-	struct ctrl_buf *buf;
 
 	if (debug & DBG_HFC_CALL_TRACE)
 		printk(KERN_DEBUG "%s: %s\n", hw->name, __func__);
 
 	urb->dev = hw->dev;
 	if (hw->ctrl_cnt) {
-		buf = &hw->ctrl_buff[hw->ctrl_out_idx];
 		hw->ctrl_cnt--;	/* decrement actual count */
 		if (++hw->ctrl_out_idx >= HFC_CTRL_BUFSIZE)
 			hw->ctrl_out_idx = 0;	/* pointer wrap */
@@ -1726,7 +1724,6 @@ hfcsusb_stop_endpoint(struct hfcsusb *hw, int channel)
 static int
 setup_hfcsusb(struct hfcsusb *hw)
 {
-	int err;
 	u_char b;
 
 	if (debug & DBG_HFC_CALL_TRACE)
@@ -1745,7 +1742,7 @@ setup_hfcsusb(struct hfcsusb *hw)
 	}
 
 	/* first set the needed config, interface and alternate */
-	err = usb_set_interface(hw->dev, hw->if_used, hw->alt_used);
+	(void) usb_set_interface(hw->dev, hw->if_used, hw->alt_used);
 
 	hw->led_state = 0;
 
-- 
1.7.4.3

