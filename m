From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 2/3] d80211-bcm43xx: Add control structure for beacontemplates
Date: Sat, 3 Feb 2007 17:25:21 +0100
Message-ID: <200702031725.21428.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@suse.cz>,
	"John Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:20470 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946486AbXBCQZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 11:25:40 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1597470nfa
        for <netdev@vger.kernel.org>; Sat, 03 Feb 2007 08:25:39 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drivers that require beacon templates will also have the
control structure at their disposal and should always free it.

bcm43xx doesn't use the control structure, but should still free it.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 9f4d51d..24be8f5 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -2732,8 +2732,10 @@ static int bcm43xx_config_interface(struct ieee80211_hw *hw,
 		if (bcm43xx_is_mode(wl, IEEE80211_IF_TYPE_AP)) {
 			assert(conf->type == IEEE80211_IF_TYPE_AP);
 			bcm43xx_set_ssid(dev, conf->ssid, conf->ssid_len);
-			if (conf->beacon)
+			if (conf->beacon) {
 				bcm43xx_refresh_templates(dev, conf->beacon);
+				kfree(conf->beacon_control);
+			}
 		}
 	}
 	spin_unlock_irqrestore(&wl->irq_lock, flags);
