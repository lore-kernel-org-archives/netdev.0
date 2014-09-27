From: Nicholas Krause <yocto6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] wireless: Remove unnessary write over of register 11 in rt2800lib.c
Date: Sat, 27 Sep 2014 17:11:41 -0400
Message-ID: <1411852301-26857-1-git-send-email-yocto6@gmail.com>
Cc: helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This removes the unnecessary  overwrite of register 11 in the function,
rt2800_config_channel as we are already writing a correct value to the
register with rt2800_rfcsr_write(rt2x00dev,11.rfcsr).

Signed-off-by: Nicholas Krause <yocto6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/rt2x00/rt2800lib.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index 893c9d5..fb0ae38 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -2787,8 +2787,6 @@ static void rt2800_config_channel_rf55xx(struct rt2x00_dev *rt2x00dev,
 
 	if (rf->channel <= 14) {
 		rt2800_rfcsr_write(rt2x00dev, 10, 0x90);
-		/* FIXME: RF11 owerwrite ? */
-		rt2800_rfcsr_write(rt2x00dev, 11, 0x4A);
 		rt2800_rfcsr_write(rt2x00dev, 12, 0x52);
 		rt2800_rfcsr_write(rt2x00dev, 13, 0x42);
 		rt2800_rfcsr_write(rt2x00dev, 22, 0x40);
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
