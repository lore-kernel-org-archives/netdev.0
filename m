From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] d80211: extend extra_hdr_room to be a bytecount
Date: Wed, 11 Oct 2006 11:58:28 +0200
Message-ID: <200610111158.28434.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:42657
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751068AbWJKJ7E
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 05:59:04 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extend ieee80211_hw's extra_hdr_room to be a bytecount for
a device specific TX header instead of being a hardcoded
0/2 byte choice.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

diff --git a/include/net/d80211.h b/include/net/d80211.h
index a80f48b..9e9709f 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -476,10 +476,6 @@ struct ieee80211_hw {
 	/* Force software encryption for TKIP packets if WMM is enabled. */
 	unsigned int no_tkip_wmm_hwaccel:1;
 
-	/* set if the payload needs to be padded at even boundaries after the
-	 * header */
-	unsigned int extra_hdr_room:1;
-
 	/* Some devices handle Michael MIC internally and do not include MIC in
 	 * the received packets passed up. device_strips_mic must be set
 	 * for such devices. The 'encryption' frame control bit is expected to
@@ -496,6 +492,9 @@ struct ieee80211_hw {
 	 * i.e. more than one skb per frame */
 	unsigned int fraglist:1;
 
+	/* Set to the size of a needed device specific skb headroom for TX skbs. */
+	unsigned int extra_hdr_room;
+
         /* This is the time in us to change channels
          */
         int channel_change_time;
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 1ef2707..7d52c3b 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1551,7 +1551,7 @@ static int ieee80211_subif_start_xmit(st
 	 * build in headroom in __dev_alloc_skb() (linux/skbuff.h) and
 	 * alloc_skb() (net/core/skbuff.c)
 	 */
-	head_need = hdrlen + encaps_len + (local->hw->extra_hdr_room ? 2 : 0);
+	head_need = hdrlen + encaps_len + local->hw->extra_hdr_room;
 	head_need -= skb_headroom(skb);
 
 	/* We are going to modify skb data, so make a copy of it if happens to


-- 
Greetings Michael.
