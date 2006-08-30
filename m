From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6.18] WE-21 for bcm43xx (wireless-2.6 git)
Date: Tue, 29 Aug 2006 18:12:11 -0700
Message-ID: <20060830011211.GO8405@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:43757 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S932174AbWH3BMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 21:12:49 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Michael Buesch <mbuesch@freenet.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

        Hi,

        WE-21 for Broadcom driver and SoftMAC...
	This version is for wireless-2.6 git.

        Jean

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/net/ieee80211/softmac/ieee80211softmac_wx.20.c linux/net/ieee80211/softmac/ieee80211softmac_wx.c
--- linux/net/ieee80211/softmac/ieee80211softmac_wx.20.c	2006-08-29 14:45:56.000000000 -0700
+++ linux/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-08-29 14:46:24.000000000 -0700
@@ -80,10 +80,10 @@ ieee80211softmac_wx_set_essid(struct net
 	 * If it's our network, ignore the change, we're already doing it!
 	 */
 	if((sm->associnfo.associating || sm->associated) &&
-	   (data->essid.flags && data->essid.length && extra)) {
+	   (data->essid.flags && data->essid.length)) {
 		/* Get the associating network */
 		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
-		if(n && n->essid.len == (data->essid.length - 1) &&
+		if(n && (n->essid.len == data->essid.length) &&
 		   !memcmp(n->essid.data, extra, n->essid.len)) {
 			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
 				MAC_ARG(sm->associnfo.bssid));
@@ -109,8 +109,8 @@ ieee80211softmac_wx_set_essid(struct net
 	sm->associnfo.static_essid = 0;
 	sm->associnfo.assoc_wait = 0;
 
-	if (data->essid.flags && data->essid.length && extra /*required?*/) {
-		length = min(data->essid.length - 1, IW_ESSID_MAX_SIZE);
+	if (data->essid.flags && data->essid.length) {
+		length = min((int) data->essid.length, IW_ESSID_MAX_SIZE);
 		if (length) {
 			memcpy(sm->associnfo.req_essid.data, extra, length);
 			sm->associnfo.static_essid = 1;
diff -u -p linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.20.c linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
--- linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.20.c	2006-08-29 14:46:08.000000000 -0700
+++ linux/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-08-29 14:47:47.000000000 -0700
@@ -334,7 +334,7 @@ static int bcm43xx_wx_get_nick(struct ne
 	size_t len;
 
 	mutex_lock(&bcm->mutex);
-	len = strlen(bcm->nick) + 1;
+	len = strlen(bcm->nick);
 	memcpy(extra, bcm->nick, len);
 	data->data.length = (__u16)len;
 	data->data.flags = 1;
