From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/12] d80211: simplify classify_1d
Date: Wed,  3 Jan 2007 19:05:12 +0100 (CET)
Message-ID: <20070103180512.21EA33AA7ED@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42227 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751012AbXACSFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:12 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The switch in classify_1d can be simplified to a bit operation.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/wme.c |   19 ++-----------------
 1 files changed, 2 insertions(+), 17 deletions(-)

e874890656210a235fbcfe0935717f86e5d179d9
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index f26fe6c..0624ad8 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -129,24 +129,9 @@ #endif /* CONFIG_NET_SCHED */
 	ip = (struct iphdr *) (skb->data + offset);
 
 	dscp = ip->tos & 0xfc;
-	switch (dscp) {
-	case 0x20:
-		return 1;
-	case 0x40:
-		return 2;
-	case 0x60:
-		return 3;
-	case 0x80:
-		return 4;
-	case 0xa0:
-		return 5;
-	case 0xc0:
-		return 6;
-	case 0xe0:
-		return 7;
-	default:
+	if (dscp & 0x1c)
 		return 0;
-	}
+	return dscp >> 5;
 }
 
 
-- 
1.3.0

