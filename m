From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 7/12] d80211: constify ieee80211_ops pointer
Date: Wed,  3 Jan 2007 19:05:15 +0100 (CET)
Message-ID: <20070103180515.5F1833AA7F0@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42228 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751026AbXACSFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:16 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>

const-ify the ieee80211_ops pointer to allow
* The compiler to do opimizations
* The drivers to declare this structure const.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h     |    2 +-
 net/d80211/ieee80211.c   |    2 +-
 net/d80211/ieee80211_i.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

9d037dc28e7f453a2dbda17284d78ae18d15f646
diff --git a/include/net/d80211.h b/include/net/d80211.h
index dc7822f..9cecbd8 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -740,7 +740,7 @@ struct ieee80211_ops {
  * priv_data_len.
  */
 struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
-					struct ieee80211_ops *ops);
+					const struct ieee80211_ops *ops);
 
 /* Register hardware device to the IEEE 802.11 code and kernel. Low-level
  * drivers must call this function before using any other IEEE 802.11
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index c833642..a5ae8a1 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4392,7 +4392,7 @@ static void rate_control_deinitialize(st
 }
 
 struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
-					      struct ieee80211_ops *ops)
+					const struct ieee80211_ops *ops)
 {
 	struct net_device *mdev;
         struct ieee80211_local *local;
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 63077b0..6ba6a61 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -333,7 +333,7 @@ struct ieee80211_local {
 	 * it first anyway so they become a no-op */
 	struct ieee80211_hw hw;
 
-	struct ieee80211_ops *ops;
+	const struct ieee80211_ops *ops;
 
 	/* List of registered struct ieee80211_hw_mode */
 	struct list_head modes_list;
-- 
1.3.0

