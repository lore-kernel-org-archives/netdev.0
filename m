From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 1/7] d80211: allow for hardware crypto of default keys
Date: Wed, 6 Dec 2006 16:44:57 -0800
Message-ID: <20061207004457.GA16252@devicescape.com>
References: <20061207004238.540749000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:33791 "EHLO
	mail.devicescape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937850AbWLGApB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:45:01 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="hwaccel-virt-sta.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove incorrect prohibition of hardware crypto support.  This was
originally present to prevent hardware crypto when more than one
station interface was created for a single hardware device, the code
in question is no longer correct and should be removed.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -537,9 +537,7 @@ static int ieee80211_set_encryption(stru
 		}
 		key = sdata->keys[idx];
 
-		/* Disable hwaccel for default keys when the interface is not
-		 * the default one.
-		 * TODO: consider adding hwaccel support for these; at least
+		/* TODO: consider adding hwaccel support for these; at least
 		 * Atheros key cache should be able to handle this since AP is
 		 * only transmitting frames with default keys. */
 		/* FIX: hw key cache can be used when only one virtual
@@ -548,11 +546,6 @@ static int ieee80211_set_encryption(stru
 		 * must be used. This should be done automatically
 		 * based on configured station devices. For the time
 		 * being, this can be only set at compile time. */
-		/* FIXME: There is no more anything like "default
-		 * interface". We should try hwaccel if there is just one
-		 * interface - for now, hwaccel is unconditionaly
-		 * disabled. */
-		try_hwaccel = 0;
 	} else {
 		set_tx_key = 0;
 		if (idx != 0) {

--
