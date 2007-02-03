From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 3/3] d80211-p54: Add control structure for beacontemplates
Date: Sat, 3 Feb 2007 17:25:22 +0100
Message-ID: <200702031725.22885.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Benc <jbenc@suse.cz>,
	"John Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:20470 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946487AbXBCQZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 11:25:41 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1597470nfa
        for <netdev@vger.kernel.org>; Sat, 03 Feb 2007 08:25:41 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drivers that require beacon templates will also have the
control structure at their disposal and should always free it.

p54 seems to ignore the beacon that is being passed,
even though it is requesting the BEACON_TEMPLATE.
That is why I not only added a line to free the control structure
but also the beacon itself.


Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/drivers/net/wireless/d80211/p54/prism54common.c b/drivers/net/wireless/d80211/p54/prism54common.c
index fd4ea5d..5a00d65 100644
--- a/drivers/net/wireless/d80211/p54/prism54common.c
+++ b/drivers/net/wireless/d80211/p54/prism54common.c
@@ -714,6 +714,8 @@ static int p54_config_interface(struct ieee80211_hw *dev, int if_id,
 	p54_set_filter(dev, 0, dev->perm_addr, conf->bssid, 0, 1, 0, 0xF642);
 	p54_set_filter(dev, 0, dev->perm_addr, conf->bssid, 2, 0, 0, 0);
 	p54_set_leds(dev, 1, !is_multicast_ether_addr(conf->bssid), 0);
+	dev_kfree_skb(conf->beacon);
+	kfree(conf->beacon_control);
 	return 0;
 }
 
