From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/5] d80211: return correct value when loading of rate control module fails
Date: Tue,  1 Aug 2006 21:16:57 +0200 (CEST)
Message-ID: <20060801191657.F416D483A7@silver.suse.cz>
References: <20060801211530.150852000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49624 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751824AbWHATQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 15:16:56 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801211530.150852000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karol Lewandowski <kl@jasmine.eu.org>

When loading of rate_control module fails, ieee80211_register_hw returns
value from previous check. This patch fixes that.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

2a053059b358f64991ac003c48f3de1da86c33ab
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 9f883a4..41c292b 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4462,7 +4462,8 @@ int ieee80211_register_hw(struct net_dev
 	if (result < 0)
 		goto fail_if_sysfs;
 
-	if (rate_control_initialize(local) < 0) {
+	result = rate_control_initialize(local);
+	if (result < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize rate control "
 		       "algorithm\n", dev->name);
 		goto fail_rate;
-- 
1.3.0

