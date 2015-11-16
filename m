From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] rtlwifi: Delete unnecessary checks before the function call
 "kfree_skb"
Date: Mon, 16 Nov 2015 13:18:38 +0100
Message-ID: <5649C99E.2070602@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 16 Nov 2015 13:12:25 +0100

The kfree_skb() function tests whether its argument is NULL and then
returns immediately. Thus the test around the calls is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/realtek/rtlwifi/core.c                 | 3 +--
 drivers/net/wireless/realtek/rtlwifi/rtl8723com/fw_common.c | 4 +---
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index c925a4d..4ae421e 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -1833,8 +1833,7 @@ bool rtl_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *skb)
 
 	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 	pskb = __skb_dequeue(&ring->queue);
-	if (pskb)
-		kfree_skb(pskb);
+	kfree_skb(pskb);
 
 	/*this is wrong, fill_tx_cmddesc needs update*/
 	pdesc = &ring->desc[0];
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723com/fw_common.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723com/fw_common.c
index a2f5e89..6e51862 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723com/fw_common.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723com/fw_common.c
@@ -318,9 +318,7 @@ bool rtl8723_cmd_send_packet(struct ieee80211_hw *hw,
 	ring = &rtlpci->tx_ring[BEACON_QUEUE];
 
 	pskb = __skb_dequeue(&ring->queue);
-	if (pskb)
-		kfree_skb(pskb);
-
+	kfree_skb(pskb);
 	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 
 	pdesc = &ring->desc[0];
-- 
2.6.2
