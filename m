From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 1/5] d80211: Fix overflow when creating AVS header
Date: Tue, 3 Oct 2006 11:12:11 -0700
Message-ID: <20061003181211.GA19403@devicescape.com>
References: <20061003181118.537800000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-67.dex002.intermedia.net ([64.78.20.25]:53323 "EHLO
	DHOST002-67.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1750893AbWJCSMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:12:17 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="hosttime.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix overflow when converting timespec to microseconds.  Without this patch you
can get an overflow during the multiplication which can result in a negative number.
hostime is define here:

4.4 hosttime
The hosttime field is set to the current value of the host maintained
clock variable when the frame is received.

(from http://www.locustworld.com/tracker/getfile/prism2drivers/doc/capturefrm.txt)

it is a u64.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -2573,7 +2573,7 @@ ieee80211_rx_mgmt(struct net_device *dev
 		struct ieee80211_rate *rate;
 
                 jiffies_to_timespec(status->hosttime, &ts);
-		fi->hosttime = cpu_to_be64(ts.tv_sec * 1000000 +
+		fi->hosttime = cpu_to_be64((u64) ts.tv_sec * 1000000 +
 					   ts.tv_nsec / 1000);
 		fi->mactime = cpu_to_be64(status->mactime);
 		switch (status->phymode) {

--
