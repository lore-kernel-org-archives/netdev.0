From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] hostap_ap.c:hostap_add_sta(): inconsequent NULL checking
Date: Fri, 10 Mar 2006 20:10:26 +0100
Message-ID: <20060310191026.GS21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hostap@shmoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752026AbWCJTK2@vger.kernel.org>
To: jkmaline@cc.hut.fi
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted this inconsequent NULL checking 
(unconditionally dereferencing directly after checking for NULL
isn't a good idea).


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc5-mm3-full/drivers/net/wireless/hostap/hostap_ap.c.old	2006-03-10 19:30:08.000000000 +0100
+++ linux-2.6.16-rc5-mm3-full/drivers/net/wireless/hostap/hostap_ap.c	2006-03-10 19:30:43.000000000 +0100
@@ -3141,7 +3141,7 @@ int hostap_add_sta(struct ap_data *ap, u
 	if (ret == 1) {
 		sta = ap_add_sta(ap, sta_addr);
 		if (!sta)
-			ret = -1;
+			return -1;
 		sta->flags = WLAN_STA_AUTH | WLAN_STA_ASSOC;
 		sta->ap = 1;
 		memset(sta->supported_rates, 0, sizeof(sta->supported_rates));
