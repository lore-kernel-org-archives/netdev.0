From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sat, 25 Nov 2006 18:16:43 -0600
Message-ID: <4568DCEB.mailLLK1Z24PM@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

In the scan section of ieee80211softmac, network transmits are disabled.
Clearly, this does not make any sense as transmit is necessary for active
scanning, and transmits are not used when passive scanning. In addition,
when SoftMAC re-enables transmits, it may override the wishes of a driver
that may have very good reasons for disabling transmits. No specific
problems can be blamed directly on this bug, but it may be responsible
for some unexplained behavior.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

Please apply this to wireless-2.6 and push it upstream for inclusion in 2.6.19,
if possible. I will be submitting it to 2.6.18.Y.

Larry


Index: linux-2.6.19-rc5/net/ieee80211/softmac/ieee80211softmac_scan.c
===================================================================
--- linux-2.6.19-rc5.orig/net/ieee80211/softmac/ieee80211softmac_scan.c
+++ linux-2.6.19-rc5/net/ieee80211/softmac/ieee80211softmac_scan.c
@@ -47,7 +47,6 @@ ieee80211softmac_start_scan(struct ieee8
 	sm->scanning = 1;
 	spin_unlock_irqrestore(&sm->lock, flags);
 
-	netif_tx_disable(sm->ieee->dev);
 	ret = sm->start_scan(sm->dev);
 	if (ret) {
 		spin_lock_irqsave(&sm->lock, flags);
@@ -248,7 +246,6 @@ void ieee80211softmac_scan_finished(stru
 		if (net)
 			sm->set_channel(sm->dev, net->channel);
 	}
-	netif_wake_queue(sm->ieee->dev);
 	ieee80211softmac_call_events(sm, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, NULL);
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_scan_finished);

---
