From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/14] d80211: use BUILD_BUG_ON
Date: Wed, 27 Sep 2006 17:50:48 +0200 (CEST)
Message-ID: <20060927155048.E2C6C3BA249@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:48780 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964967AbWI0Ptn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:43 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch makes d80211 use BUILD_BUG_ON instead of checking at module
initialisation time. This check really is only interesting while you
hack since if the module was built, then it's either an 'always true' or
'always false' comparison, hence useless to do it at runtime.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

156023b8efbec8a72f7077934d7b12cf1d00fb95
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 320272c..76ecad8 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4799,13 +4799,8 @@ static int __init ieee80211_init(void)
 	struct sk_buff *skb;
 	int ret;
 
-	if (sizeof(struct ieee80211_tx_packet_data) > (sizeof(skb->cb))) {
-		printk("80211: ieee80211_tx_packet_data is bigger "
-		       "than the skb->cb (%d > %d)\n",
-		       (int) sizeof(struct ieee80211_tx_packet_data),
-		       (int) sizeof(skb->cb));
-		return -EINVAL;
-	}
+	BUILD_BUG_ON(sizeof(struct ieee80211_tx_packet_data) > sizeof(skb->cb));
+
 	if ((ret = ieee80211_sysfs_init())) {
 		printk(KERN_WARNING "ieee80211_init: sysfs initialization "
 		       "failed\n");
-- 
1.3.0

