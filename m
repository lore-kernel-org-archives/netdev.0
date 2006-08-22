From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 2/5] d80211: fix multiple device support
Date: Tue, 22 Aug 2006 10:33:17 -0700
Message-ID: <20060822173317.GC12500@devicescape.com>
References: <20060822173241.313859000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-20.dex002.intermedia.net ([64.78.21.87]:46951 "EHLO
	dhost002-20.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932323AbWHVRdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 13:33:20 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="dev_alloc_name-retval.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix interpretation of dev_alloc_name() return value.  dev_alloc_name()
returns the number of the unit assigned or a negative errno code.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_iface.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_iface.c
+++ wireless-dev/net/d80211/ieee80211_iface.c
@@ -64,7 +64,7 @@ int ieee80211_if_add(struct net_device *
 		} while (i < 10000);
 	} else if (format) {
 		ret = dev_alloc_name(ndev, name);
-		if (ret)
+		if (ret < 0)
 			goto fail;
 	} else {
 		snprintf(ndev->name, IFNAMSIZ, "%s", name);

--
