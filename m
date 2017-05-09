From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/4] hamradio: Adjust four function calls together with a
 variable assignment
Date: Tue, 9 May 2017 16:23:20 +0200
Message-ID: <28005de5-baf6-9db0-7eaa-7ef14d4e7142@users.sourceforge.net>
References: <4c5c939a-bd55-7b88-8e41-49f5544b7658@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Jean-Paul Roubelat <jpr@f6fbb.org>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4c5c939a-bd55-7b88-8e41-49f5544b7658@users.sourceforge.net>
Content-Language: en-US
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 9 May 2017 15:15:16 +0200

The script "checkpatch.pl" pointed information out like the following.

ERROR: do not use assignment in if condition

Thus fix affected source code places.
Improve a size determination.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/hamradio/yam.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 542f1e511df1..c792b0f116a5 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -401,7 +401,8 @@ static unsigned char *add_mcs(unsigned char *bits, int bitrate,
 	}
 
 	/* Allocate a new mcs */
-	if ((p = kmalloc(sizeof(struct yam_mcs), GFP_KERNEL)) == NULL) {
+	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	if (!p) {
 		release_firmware(fw);
 		return NULL;
 	}
@@ -549,7 +550,8 @@ static inline void yam_rx_flag(struct net_device *dev, struct yam_port *yp)
 		if ((yp->rx_crch & yp->rx_crcl) != 0xFF) {
 			/* Bad crc */
 		} else {
-			if (!(skb = dev_alloc_skb(pkt_len))) {
+			skb = dev_alloc_skb(pkt_len);
+			if (!skb) {
 				printk(KERN_WARNING "%s: memory squeeze, dropping packet\n", dev->name);
 				++dev->stats.rx_dropped;
 			} else {
@@ -670,7 +672,8 @@ static void yam_tx_byte(struct net_device *dev, struct yam_port *yp)
 		break;
 	case TX_HEAD:
 		if (--yp->tx_count <= 0) {
-			if (!(skb = skb_dequeue(&yp->send_queue))) {
+			skb = skb_dequeue(&yp->send_queue);
+			if (!skb) {
 				ptt_off(dev);
 				yp->tx_state = TX_OFF;
 				break;
@@ -879,7 +882,8 @@ static int yam_open(struct net_device *dev)
 		printk(KERN_ERR "%s: cannot 0x%lx busy\n", dev->name, dev->base_addr);
 		return -EACCES;
 	}
-	if ((u = yam_check_uart(dev->base_addr)) == c_uart_unknown) {
+	u = yam_check_uart(dev->base_addr);
+	if (u == c_uart_unknown) {
 		printk(KERN_ERR "%s: cannot find uart type\n", dev->name);
 		ret = -EIO;
 		goto out_release_base;
-- 
2.12.2

