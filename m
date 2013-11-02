From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 07/13] driver: staging: remove unnecessary NULL check before dev_kfree_skb_any
Date: Sat,  2 Nov 2013 19:17:48 +0530
Message-ID: <1383400074-30555-8-git-send-email-govindarajulu90@gmail.com>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com, benve@cisco.com, ssujith@cisco.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_kfree_skb_any is protected from NULL. No need to check for NULL while
calling this function.

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c |  3 +--
 drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c |  3 +--
 drivers/staging/rtl8188eu/core/rtw_recv.c          |  6 ++----
 drivers/staging/rtl8192e/rtllib_rx.c               |  3 +--
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c  |  3 +--
 drivers/staging/rtl8712/recv_linux.c               |  3 +--
 drivers/staging/rtl8712/rtl8712_recv.c             |  6 ++----
 drivers/staging/rtl8712/xmit_linux.c               |  3 +--
 drivers/staging/sbe-2t3e3/dc.c                     | 12 ++++--------
 9 files changed, 14 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c
index 10b2210..bbafdcc 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_rx.c
@@ -138,8 +138,7 @@ ieee80211_frag_cache_get(struct ieee80211_device *ieee,
 		if (ieee->frag_next_idx[tid] >= IEEE80211_FRAG_CACHE_LEN)
 			ieee->frag_next_idx[tid] = 0;
 
-		if (entry->skb != NULL)
-			dev_kfree_skb_any(entry->skb);
+		dev_kfree_skb_any(entry->skb);
 
 		entry->first_frag_time = jiffies;
 		entry->seq = seq;
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
index b346653..fe747b1 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
@@ -234,8 +234,7 @@ void ieee80211_txb_free(struct ieee80211_txb *txb) {
 	if (unlikely(!txb))
 		return;
 	for (i = 0; i < txb->nr_frags; i++)
-		if (txb->fragments[i])
-			dev_kfree_skb_any(txb->fragments[i]);
+		dev_kfree_skb_any(txb->fragments[i]);
 	kfree(txb);
 }
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 2011657..93fb9ed 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -209,10 +209,8 @@ int rtw_free_recvframe(union recv_frame *precvframe, struct __queue *pfree_recv_
 
 _func_enter_;
 
-	if (precvframe->u.hdr.pkt) {
-		dev_kfree_skb_any(precvframe->u.hdr.pkt);/* free skb by driver */
-		precvframe->u.hdr.pkt = NULL;
-	}
+	dev_kfree_skb_any(precvframe->u.hdr.pkt);/* free skb by driver */
+	precvframe->u.hdr.pkt = NULL;
 
 	_enter_critical_bh(&pfree_recv_queue->lock, &irqL);
 
diff --git a/drivers/staging/rtl8192e/rtllib_rx.c b/drivers/staging/rtl8192e/rtllib_rx.c
index 8aeaed5..0118854 100644
--- a/drivers/staging/rtl8192e/rtllib_rx.c
+++ b/drivers/staging/rtl8192e/rtllib_rx.c
@@ -133,8 +133,7 @@ rtllib_frag_cache_get(struct rtllib_device *ieee,
 		if (ieee->frag_next_idx[tid] >= RTLLIB_FRAG_CACHE_LEN)
 			ieee->frag_next_idx[tid] = 0;
 
-		if (entry->skb != NULL)
-			dev_kfree_skb_any(entry->skb);
+		dev_kfree_skb_any(entry->skb);
 
 		entry->first_frag_time = jiffies;
 		entry->seq = seq;
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
index 59900bf..70bf7a4 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
@@ -138,8 +138,7 @@ ieee80211_frag_cache_get(struct ieee80211_device *ieee,
 		if (ieee->frag_next_idx[tid] >= IEEE80211_FRAG_CACHE_LEN)
 			ieee->frag_next_idx[tid] = 0;
 
-		if (entry->skb != NULL)
-			dev_kfree_skb_any(entry->skb);
+		dev_kfree_skb_any(entry->skb);
 
 		entry->first_frag_time = jiffies;
 		entry->seq = seq;
diff --git a/drivers/staging/rtl8712/recv_linux.c b/drivers/staging/rtl8712/recv_linux.c
index 495ee12..c422d1f 100644
--- a/drivers/staging/rtl8712/recv_linux.c
+++ b/drivers/staging/rtl8712/recv_linux.c
@@ -75,8 +75,7 @@ int r8712_os_recvbuf_resource_alloc(struct _adapter *padapter,
 int r8712_os_recvbuf_resource_free(struct _adapter *padapter,
 			     struct recv_buf *precvbuf)
 {
-	if (precvbuf->pskb)
-		dev_kfree_skb_any(precvbuf->pskb);
+	dev_kfree_skb_any(precvbuf->pskb);
 	if (precvbuf->purb) {
 		usb_kill_urb(precvbuf->purb);
 		usb_free_urb(precvbuf->purb);
diff --git a/drivers/staging/rtl8712/rtl8712_recv.c b/drivers/staging/rtl8712/rtl8712_recv.c
index d59a74a..9a4e87c 100644
--- a/drivers/staging/rtl8712/rtl8712_recv.c
+++ b/drivers/staging/rtl8712/rtl8712_recv.c
@@ -145,10 +145,8 @@ int r8712_free_recvframe(union recv_frame *precvframe,
 	struct _adapter *padapter = precvframe->u.hdr.adapter;
 	struct recv_priv *precvpriv = &padapter->recvpriv;
 
-	if (precvframe->u.hdr.pkt) {
-		dev_kfree_skb_any(precvframe->u.hdr.pkt);/*free skb by driver*/
-		precvframe->u.hdr.pkt = NULL;
-	}
+	dev_kfree_skb_any(precvframe->u.hdr.pkt);/*free skb by driver*/
+	precvframe->u.hdr.pkt = NULL;
 	spin_lock_irqsave(&pfree_recv_queue->lock, irqL);
 	list_delete(&(precvframe->u.hdr.list));
 	list_insert_tail(&(precvframe->u.hdr.list),
diff --git a/drivers/staging/rtl8712/xmit_linux.c b/drivers/staging/rtl8712/xmit_linux.c
index 4d22bb7..13bb27a 100644
--- a/drivers/staging/rtl8712/xmit_linux.c
+++ b/drivers/staging/rtl8712/xmit_linux.c
@@ -156,8 +156,7 @@ void r8712_xmit_resource_free(struct _adapter *padapter,
 
 void r8712_xmit_complete(struct _adapter *padapter, struct xmit_frame *pxframe)
 {
-	if (pxframe->pkt)
-		dev_kfree_skb_any(pxframe->pkt);
+	dev_kfree_skb_any(pxframe->pkt);
 	pxframe->pkt = NULL;
 }
 
diff --git a/drivers/staging/sbe-2t3e3/dc.c b/drivers/staging/sbe-2t3e3/dc.c
index f207b9e..d8c9464 100644
--- a/drivers/staging/sbe-2t3e3/dc.c
+++ b/drivers/staging/sbe-2t3e3/dc.c
@@ -403,10 +403,8 @@ void dc_clear_descriptor_list(struct channel *sc)
 
 	/* free all data buffers on TX ring */
 	for (i = 0; i < SBE_2T3E3_TX_DESC_RING_SIZE; i++) {
-		if (sc->ether.tx_data[i] != NULL) {
-			dev_kfree_skb_any(sc->ether.tx_data[i]);
-			sc->ether.tx_data[i] = NULL;
-		}
+		dev_kfree_skb_any(sc->ether.tx_data[i]);
+		sc->ether.tx_data[i] = NULL;
 	}
 }
 
@@ -418,10 +416,8 @@ void dc_drop_descriptor_list(struct channel *sc)
 
 	/* free all data buffers on RX ring */
 	for (i = 0; i < SBE_2T3E3_RX_DESC_RING_SIZE; i++) {
-		if (sc->ether.rx_data[i] != NULL) {
-			dev_kfree_skb_any(sc->ether.rx_data[i]);
-			sc->ether.rx_data[i] = NULL;
-		}
+		dev_kfree_skb_any(sc->ether.rx_data[i]);
+		sc->ether.rx_data[i] = NULL;
 	}
 
 	kfree(sc->ether.rx_ring);
-- 
1.8.4.2
