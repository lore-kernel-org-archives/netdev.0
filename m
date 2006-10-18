From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 17/18] d80211: Fix TX/RX rates
Date: Wed, 18 Oct 2006 17:49:41 +0200 (CEST)
Message-ID: <20061018154941.205923AA6B9@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:16546 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161199AbWJRPtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:49:11 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Modestas Vainius <geromanas@mailas.com>

This patch correctly initializes the force_unicast_rateidx
and max_ratectrl_rateidx. This was not done previously
and caused a bug in rf80211_simple where when
rate_control_simple_get_rate() was called, the incorrect
rate was selected from the list.

Signed-off-by: Modestas Vainius <geromanas@mailas.com>
Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

0fbc8104060588dab4db93f37e3cdfb86ffed062
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 50b2b29..32a1ba7 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4414,6 +4414,8 @@ struct net_device *ieee80211_alloc_hw(si
         sdata->dev = mdev;
         sdata->master = mdev;
         sdata->local = local;
+	sdata->u.ap.force_unicast_rateidx = -1;
+	sdata->u.ap.max_ratectrl_rateidx = -1;
 	ieee80211_if_sdata_init(sdata);
         list_add_tail(&sdata->list, &local->sub_if_list);
 
-- 
1.3.0

