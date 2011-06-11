From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] ISDN, hfcsusb: Don't leak in hfcsusb_ph_info()
Date: Sat, 11 Jun 2011 18:36:42 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106111832270.23835@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Sprenger <sprenger@moving-bytes.de>,
	Martin Bachem <info@bachem-it.com>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We leak the memory allocated to 'phi' when the variable goes out of scope 
in hfcsusb_ph_info().

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 hfcsusb.c |    1 +
 1 file changed, 1 insertion(+)

 I have no way to really test this patch, so it is only compile tested.

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 3ccbff1..71a8eb6 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -283,6 +283,7 @@ hfcsusb_ph_info(struct hfcsusb *hw)
 	_queue_data(&dch->dev.D, MPH_INFORMATION_IND, MISDN_ID_ANY,
 		sizeof(struct ph_info_dch) + dch->dev.nrbchan *
 		sizeof(struct ph_info_ch), phi, GFP_ATOMIC);
+	kfree(phi);
 }
 
 /*


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
