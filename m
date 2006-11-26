From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] softmac: reduce scan debug output
Date: Sat, 25 Nov 2006 18:30:03 -0600
Message-ID: <4568E00B.mailM4211XMRP@lwfinger.net>
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

When scanning in debug mode, softmac is very chatty in that it puts 3 lines
in the logs for each time it scans. This patch has only one line containing
all the information previously reported.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

Please apply this to wireless-2.6.

Larry


Index: linux-2.6/net/ieee80211/softmac/ieee80211softmac_scan.c
===================================================================
--- linux-2.6.orig/net/ieee80211/softmac/ieee80211softmac_scan.c
+++ linux-2.6/net/ieee80211/softmac/ieee80211softmac_scan.c
@@ -134,7 +134,8 @@ void ieee80211softmac_scan(void *d)
 	si->started = 0;
 	spin_unlock_irqrestore(&sm->lock, flags);
 
-	dprintk(PFX "Scanning finished\n");
+	dprintk(PFX "Scanning finished: scanned %d channels starting with channel %d\n",
+		     sm->scaninfo->number_channels, sm->scaninfo->channels[0].channel);
 	ieee80211softmac_scan_finished(sm);
 	complete_all(&sm->scaninfo->finished);
 }
@@ -182,8 +183,6 @@ int ieee80211softmac_start_scan_implemen
 		sm->scaninfo->channels = sm->ieee->geo.bg;
 		sm->scaninfo->number_channels = sm->ieee->geo.bg_channels;
 	}
-	dprintk(PFX "Start scanning with channel: %d\n", sm->scaninfo->channels[0].channel);
-	dprintk(PFX "Scanning %d channels\n", sm->scaninfo->number_channels);
 	sm->scaninfo->current_channel_idx = 0;
 	sm->scaninfo->started = 1;
 	sm->scaninfo->stop = 0;
