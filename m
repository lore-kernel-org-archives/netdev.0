From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/12] d80211: deinit sysfs in case of an error
Date: Thu,  8 Jun 2006 09:49:05 +0200 (CEST)
Message-ID: <20060608074905.04E8F4838F@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51096 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932561AbWFHHry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:47:54 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When ieee80211_wme_register fails in ieee80211_init, ieee80211 class was not
unregistered.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

3aed246a5117bd4d1a4f2d5f5074c583d9b4941e
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index b850fb7..f549098 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4462,6 +4462,7 @@ static int __init ieee80211_init(void)
 		if (ret) {
 			printk(KERN_DEBUG "ieee80211_init: failed to "
 			       "initialize WME (err=%d)\n", ret);
+			ieee80211_sysfs_deinit();
 			ieee80211_proc_deinit();
 			return ret;
 		}
-- 
1.3.0

