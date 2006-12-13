From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/14] d80211: fix potential interface name overflow
Date: Wed, 13 Dec 2006 17:41:38 +0100 (CET)
Message-ID: <20061213164138.53AC33AA6BB@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57261 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965034AbWLMRIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:53 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

dev->name and ndev->name are both IFNAMSIZ in length, the ".%d" is
not guarenteed to fit in ndev->name.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_iface.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

e268081fcce1027a23420bfe74c59bf130742bce
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index ae1fb9e..bb15442 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -56,7 +56,8 @@ int ieee80211_if_add(struct net_device *
 	if (strlen(name) == 0) {
 		i = 0;
 		do {
-			sprintf(ndev->name, "%s.%d", dev->name, i++);
+			snprintf(ndev->name, sizeof(ndev->name), "%s.%d",
+				 dev->name, i++);
 			tmp_dev = dev_get_by_name(ndev->name);
 			if (!tmp_dev)
 				break;
-- 
1.3.0

