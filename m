From: Joe Perches <joe@perches.com>
Subject: [PATCH] ieee80211_i.h: Align struct ps_data.tim to unsigned long
Date: Wed, 18 Dec 2013 16:52:17 -0800
Message-ID: <1387414337.13593.48.camel@joe-AO722>
References: <1387354564.13593.26.camel@joe-AO722>
	 (sfid-20131218_091612_149215_EA847147) <1387358347.4694.2.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@redhat.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0197.hostedemail.com ([216.40.44.197]:43404 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751877Ab3LSAwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:52:23 -0500
In-Reply-To: <1387358347.4694.2.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its address is used as an unsigned long *, so make sure
that the tim u8 array is properly aligned.

Signed-off-by: Joe Perches <joe@perches.com
---
> Care to send a proper patch? Otherwise I'll just re-do it and pick it up
> that way ...

I had a passing thought about this when out today.
It should really be set to __aligned(__alignof(unsigned long))
so here's a proper patch.

 net/mac80211/ieee80211_i.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index ed5bf8b..9a61eef 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -245,7 +245,8 @@ struct ps_data {
 	/* yes, this looks ugly, but guarantees that we can later use
 	 * bitmap_empty :)
 	 * NB: don't touch this bitmap, use sta_info_{set,clear}_tim_bit */
-	u8 tim[sizeof(unsigned long) * BITS_TO_LONGS(IEEE80211_MAX_AID + 1)];
+	u8 tim[sizeof(unsigned long) * BITS_TO_LONGS(IEEE80211_MAX_AID + 1)]
+			__aligned(__alignof__(unsigned long));
 	struct sk_buff_head bc_buf;
 	atomic_t num_sta_ps; /* number of stations in PS mode */
 	int dtim_count;
