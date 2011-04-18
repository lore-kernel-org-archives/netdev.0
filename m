From: David Miller <davem@davemloft.net>
Subject: [PATCH 21/42] isdn: hfc_usb: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:36 -0700 (PDT)
Message-ID: <20110417.173336.15235624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51048
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753926Ab1DRAeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:11 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A71B924C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'buf' is set but unused in
ctrl_complete().  Just kill it off.

Similarly for 'err' in hfc_usb_init().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/hfc_usb.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/hisax/hfc_usb.c b/drivers/isdn/hisax/hfc_usb.c
index ed9527a..f407de0 100644
--- a/drivers/isdn/hisax/hfc_usb.c
+++ b/drivers/isdn/hisax/hfc_usb.c
@@ -258,11 +258,9 @@ static void
 ctrl_complete(struct urb *urb)
 {
 	hfcusb_data *hfc = (hfcusb_data *) urb->context;
-	ctrl_buft *buf;
 
 	urb->dev = hfc->dev;
 	if (hfc->ctrl_cnt) {
-		buf = &hfc->ctrl_buff[hfc->ctrl_out_idx];
 		hfc->ctrl_cnt--;	/* decrement actual count */
 		if (++hfc->ctrl_out_idx >= HFC_CTRL_BUFSIZE)
 			hfc->ctrl_out_idx = 0;	/* pointer wrap */
@@ -1097,7 +1095,7 @@ static int
 hfc_usb_init(hfcusb_data * hfc)
 {
 	usb_fifo *fifo;
-	int i, err;
+	int i;
 	u_char b;
 	struct hisax_b_if *p_b_if[2];
 
@@ -1112,7 +1110,7 @@ hfc_usb_init(hfcusb_data * hfc)
 	}
 
 	/* first set the needed config, interface and alternate */
-	err = usb_set_interface(hfc->dev, hfc->if_used, hfc->alt_used);
+	usb_set_interface(hfc->dev, hfc->if_used, hfc->alt_used);
 
 	/* do Chip reset */
 	write_usb(hfc, HFCUSB_CIRM, 8);
-- 
1.7.4.3

