From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: fix usage of capability field for ibss mode
Date: Sun, 12 Nov 2006 10:15:05 -0800
Message-ID: <20061112181505.GB13434@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:62170 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1752125AbWKLSPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Nov 2006 13:15:05 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="bss_capability_endian.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks to sparse for pointing out these errors.

'capability' is stored in struct ieee80211_sta_bss in host byte order, do not
swap bytes.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_sta.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-11-05 14:53:19.602141912 -0800
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-11-05 15:12:52.937767784 -0800
@@ -1984,7 +1984,7 @@
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	sdata->drop_unencrypted = bss->capability &
-		cpu_to_le16(WLAN_CAPABILITY_PRIVACY) ? 1 : 0;
+		WLAN_CAPABILITY_PRIVACY ? 1 : 0;
 
 	memset(&rq, 0, sizeof(rq));
 	rq.m = bss->freq * 100000;
@@ -2153,9 +2153,9 @@
 	bss->channel = local->conf.channel;
 	bss->freq = local->conf.freq;
 	bss->last_update = jiffies;
-	bss->capability = cpu_to_le16(WLAN_CAPABILITY_IBSS);
+	bss->capability = WLAN_CAPABILITY_IBSS;
 	if (sdata->default_key) {
-		bss->capability |= cpu_to_le16(WLAN_CAPABILITY_PRIVACY);
+		bss->capability |= WLAN_CAPABILITY_PRIVACY;
 	} else
 		sdata->drop_unencrypted = 0;
 	bss->supp_rates_len = local->num_curr_rates;

--
