From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/12] d80211: fix classify_1d() priority selection
Date: Wed,  3 Jan 2007 19:05:11 +0100 (CET)
Message-ID: <20070103180511.14E7E3AA7EB@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42225 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751005AbXACSFL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:11 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhu Yi <yi.zhu@intel.com>

I don't see any reason why packets with DSCP=0x40 should have lower IEEE
802.1D priority than packets with DSCP=0x20. Spare > Background. No?

Signed-off-by: Zhu Yi <yi.zhu@intel.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/wme.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

d131a5bef49c2d56e0a7063aaa8753b4749144d1
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index b9505dc..f26fe6c 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -131,9 +131,9 @@ #endif /* CONFIG_NET_SCHED */
 	dscp = ip->tos & 0xfc;
 	switch (dscp) {
 	case 0x20:
-		return 2;
-	case 0x40:
 		return 1;
+	case 0x40:
+		return 2;
 	case 0x60:
 		return 3;
 	case 0x80:
-- 
1.3.0

