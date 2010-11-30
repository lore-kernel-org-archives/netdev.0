From: Joe Perches <joe@perches.com>
Subject: [PATCH] ath9k: hif_usb: Reduce indent 1 column
Date: Tue, 30 Nov 2010 12:19:11 -0800
Message-ID: <75c6310f61e2df007dfe87c4cafbfeb0482ae569.1291148304.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Invert test and return early.
Move variable declarations to local scope.
Don't initialize variables to 0 unnecessarily.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath9k/hif_usb.c |  106 +++++++++++++++---------------
 1 files changed, 53 insertions(+), 53 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index ae842db..63bf9a7 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -363,9 +363,9 @@ static void ath9k_hif_usb_rx_stream(struct hif_device_usb *hif_dev,
 				    struct sk_buff *skb)
 {
 	struct sk_buff *nskb, *skb_pool[MAX_PKT_NUM_IN_TRANSFER];
-	int index = 0, i = 0, chk_idx, len = skb->len;
-	int rx_remain_len = 0, rx_pkt_len = 0;
-	u16 pkt_len, pkt_tag, pool_index = 0;
+	int index = 0, i = 0, len = skb->len;
+	int rx_remain_len, rx_pkt_len;
+	u16 pool_index = 0;
 	u8 *ptr;
 
 	spin_lock(&hif_dev->rx_lock);
@@ -399,64 +399,64 @@ static void ath9k_hif_usb_rx_stream(struct hif_device_usb *hif_dev,
 	spin_unlock(&hif_dev->rx_lock);
 
 	while (index < len) {
+		u16 pkt_len;
+		u16 pkt_tag;
+		u16 pad_len;
+		int chk_idx;
+
 		ptr = (u8 *) skb->data;
 
 		pkt_len = ptr[index] + (ptr[index+1] << 8);
 		pkt_tag = ptr[index+2] + (ptr[index+3] << 8);
 
-		if (pkt_tag == ATH_USB_RX_STREAM_MODE_TAG) {
-			u16 pad_len;
-
-			pad_len = 4 - (pkt_len & 0x3);
-			if (pad_len == 4)
-				pad_len = 0;
-
-			chk_idx = index;
-			index = index + 4 + pkt_len + pad_len;
-
-			if (index > MAX_RX_BUF_SIZE) {
-				spin_lock(&hif_dev->rx_lock);
-				hif_dev->rx_remain_len = index - MAX_RX_BUF_SIZE;
-				hif_dev->rx_transfer_len =
-					MAX_RX_BUF_SIZE - chk_idx - 4;
-				hif_dev->rx_pad_len = pad_len;
-
-				nskb = __dev_alloc_skb(pkt_len + 32,
-						       GFP_ATOMIC);
-				if (!nskb) {
-					dev_err(&hif_dev->udev->dev,
-					"ath9k_htc: RX memory allocation"
-					" error\n");
-					spin_unlock(&hif_dev->rx_lock);
-					goto err;
-				}
-				skb_reserve(nskb, 32);
-				RX_STAT_INC(skb_allocated);
-
-				memcpy(nskb->data, &(skb->data[chk_idx+4]),
-				       hif_dev->rx_transfer_len);
-
-				/* Record the buffer pointer */
-				hif_dev->remain_skb = nskb;
+		if (pkt_tag != ATH_USB_RX_STREAM_MODE_TAG) {
+			RX_STAT_INC(skb_dropped);
+			return;
+		}
+
+		pad_len = 4 - (pkt_len & 0x3);
+		if (pad_len == 4)
+			pad_len = 0;
+
+		chk_idx = index;
+		index = index + 4 + pkt_len + pad_len;
+
+		if (index > MAX_RX_BUF_SIZE) {
+			spin_lock(&hif_dev->rx_lock);
+			hif_dev->rx_remain_len = index - MAX_RX_BUF_SIZE;
+			hif_dev->rx_transfer_len =
+				MAX_RX_BUF_SIZE - chk_idx - 4;
+			hif_dev->rx_pad_len = pad_len;
+
+			nskb = __dev_alloc_skb(pkt_len + 32, GFP_ATOMIC);
+			if (!nskb) {
+				dev_err(&hif_dev->udev->dev,
+					"ath9k_htc: RX memory allocation error\n");
 				spin_unlock(&hif_dev->rx_lock);
-			} else {
-				nskb = __dev_alloc_skb(pkt_len + 32, GFP_ATOMIC);
-				if (!nskb) {
-					dev_err(&hif_dev->udev->dev,
-					"ath9k_htc: RX memory allocation"
-					" error\n");
-					goto err;
-				}
-				skb_reserve(nskb, 32);
-				RX_STAT_INC(skb_allocated);
-
-				memcpy(nskb->data, &(skb->data[chk_idx+4]), pkt_len);
-				skb_put(nskb, pkt_len);
-				skb_pool[pool_index++] = nskb;
+				goto err;
 			}
+			skb_reserve(nskb, 32);
+			RX_STAT_INC(skb_allocated);
+
+			memcpy(nskb->data, &(skb->data[chk_idx+4]),
+			       hif_dev->rx_transfer_len);
+
+			/* Record the buffer pointer */
+			hif_dev->remain_skb = nskb;
+			spin_unlock(&hif_dev->rx_lock);
 		} else {
-			RX_STAT_INC(skb_dropped);
-			return;
+			nskb = __dev_alloc_skb(pkt_len + 32, GFP_ATOMIC);
+			if (!nskb) {
+				dev_err(&hif_dev->udev->dev,
+					"ath9k_htc: RX memory allocation error\n");
+				goto err;
+			}
+			skb_reserve(nskb, 32);
+			RX_STAT_INC(skb_allocated);
+
+			memcpy(nskb->data, &(skb->data[chk_idx+4]), pkt_len);
+			skb_put(nskb, pkt_len);
+			skb_pool[pool_index++] = nskb;
 		}
 	}
 
-- 
1.7.3.2.245.g03276.dirty
