From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: fix multiple device ap support
Date: Tue, 5 Sep 2006 11:50:35 -0700
Message-ID: <20060905185035.GA24499@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-70.dex002.intermedia.net ([64.78.20.36]:37928 "EHLO
	DHOST002-70.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1030214AbWIESuk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 14:50:40 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="dev_alloc_name-retval.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Another fix to the interpretation of dev_alloc_name() return value.
dev_alloc_name() returns the number of the unit assigned or a negative
errno code.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: linux-2.6.16/net/d80211/ieee80211_iface.c
===================================================================
--- linux-2.6.16.orig/net/d80211/ieee80211_iface.c
+++ linux-2.6.16/net/d80211/ieee80211_iface.c
@@ -122,7 +122,7 @@ int ieee80211_if_add_mgmt(struct net_dev
 	if (!ndev)
 		return -ENOMEM;
 	ret = dev_alloc_name(ndev, "wmgmt%d");
-	if (ret)
+	if (ret < 0)
 		goto fail;
 
 	ndev->ieee80211_ptr = local;

--
