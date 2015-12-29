From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] mISDN: correctly handling failed allocation
Date: Tue, 29 Dec 2015 16:38:46 -0500
Message-ID: <1451425126-26958-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu, Insu Yun <wuninsu@gmail.com>
To: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since kzalloc can be failed in memory pressure,
NULL dereference might be happened.

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 drivers/isdn/hardware/mISDN/hfcsusb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/isdn/hardware/mISDN/hfcsusb.c b/drivers/isdn/hardware/mISDN/hfcsusb.c
index 114f3bc..15164e9 100644
--- a/drivers/isdn/hardware/mISDN/hfcsusb.c
+++ b/drivers/isdn/hardware/mISDN/hfcsusb.c
@@ -264,6 +264,9 @@ hfcsusb_ph_info(struct hfcsusb *hw)
 
 	phi = kzalloc(sizeof(struct ph_info) +
 		      dch->dev.nrbchan * sizeof(struct ph_info_ch), GFP_ATOMIC);
+	if (!phi)
+		return;
+
 	phi->dch.ch.protocol = hw->protocol;
 	phi->dch.ch.Flags = dch->Flags;
 	phi->dch.state = dch->state;
-- 
1.9.1
