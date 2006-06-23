From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/5] d80211: update tx.skb after TX handler calls
Date: Fri, 23 Jun 2006 15:01:18 +0200 (CEST)
Message-ID: <20060623130118.A6CD0483AB@silver.suse.cz>
References: <20060623150047.368594000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:10887 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964799AbWFWM74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 08:59:56 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060623150047.368594000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TX and RX handlers are allowed to change skb. Fix (hopefully) the last place
where this is not taken into account.

This is similar to e81b1bc0f272a50458ab6ae8777f6327af0248e5.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

9372ebe184ff953be4f9d05b029477a57dd43bbd
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index a8ca8d1..944b89f 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1760,6 +1760,7 @@ ieee80211_get_buffered_bc(struct net_dev
 			break;
 	}
 	dev_put(tx.dev);
+	skb = tx.skb; /* handlers are allowed to change skb */
 
 	if (res == TXRX_DROP) {
 		I802_DEBUG_INC(local->tx_handlers_drop);
-- 
1.3.0

