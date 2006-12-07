From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 3/7] d80211: fix potential interface name overflow
Date: Wed, 6 Dec 2006 16:45:11 -0800
Message-ID: <20061207004511.GC16252@devicescape.com>
References: <20061207004238.540749000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:33812 "EHLO
	mail.devicescape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937855AbWLGApM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:45:12 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="ieee80211_if_add-snprintf.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev->name and ndev->name are both IFNAMSIZ in length, the ".%d" is
not guarenteed to fit in ndev->name.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_iface.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_iface.c
+++ wireless-dev/net/d80211/ieee80211_iface.c
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
