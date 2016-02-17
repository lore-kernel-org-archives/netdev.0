From: Anton Protopopov <a.s.protopopov@gmail.com>
Subject: [PATCH] mISDN: prevent possible NULL pointer dereference
Date: Wed, 17 Feb 2016 11:19:56 -0500
Message-ID: <1455725996-10538-1-git-send-email-a.s.protopopov@gmail.com>
Cc: Anton Protopopov <a.s.protopopov@gmail.com>
To: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A return value of the bchannel_get_rxbuf() function is compared with the
positive ENOMEM value instead of the negative -ENOMEM value to detect a
memory allocation problem. Thus, after a possible memory allocation
failure the bc->bch.rx_skb will be NULL which will lead to a NULL
pointer dereference.

Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>
---
 drivers/isdn/hardware/mISDN/netjet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index 8e29447..afde4ed 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -392,7 +392,7 @@ read_dma(struct tiger_ch *bc, u32 idx, int cnt)
 	}
 	stat = bchannel_get_rxbuf(&bc->bch, cnt);
 	/* only transparent use the count here, HDLC overun is detected later */
-	if (stat == ENOMEM) {
+	if (stat == -ENOMEM) {
 		pr_warning("%s.B%d: No memory for %d bytes\n",
 			   card->name, bc->bch.nr, cnt);
 		return;
-- 
2.6.5
