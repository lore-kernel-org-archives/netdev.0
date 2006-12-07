From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 6/7] d80211: fix invalid check for sub interface type AP
Date: Wed, 6 Dec 2006 16:45:32 -0800
Message-ID: <20061207004532.GF16252@devicescape.com>
References: <20061207004238.540749000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:33850 "EHLO
	mail.devicescape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937840AbWLGApd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:45:33 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="sub_if_type.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should be checking the type member, not the raw pointer.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -1996,7 +1996,7 @@ static int ieee80211_ioctl_siwscan(struc
 		    sdata->type == IEEE80211_IF_TYPE_IBSS) {
 			ssid = sdata->u.sta.ssid;
 			ssid_len = sdata->u.sta.ssid_len;
-		} else if (sdata == IEEE80211_IF_TYPE_AP) {
+		} else if (sdata->type == IEEE80211_IF_TYPE_AP) {
 			ssid = sdata->u.ap.ssid;
 			ssid_len = sdata->u.ap.ssid_len;
 		} else

--
