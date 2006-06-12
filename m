From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH] d80211: update tx.skb after TX handler calls
Date: Mon, 12 Jun 2006 21:09:22 +0200
Message-ID: <20060612210922.127e9869@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:22968 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1752184AbWFLTJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 15:09:26 -0400
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TX and RX handlers are allowed to change skb. Fix (hopefully) the last place
where this is not taken into account.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    1 +
 1 files changed, 1 insertion(+)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -1760,6 +1760,7 @@ ieee80211_get_buffered_bc(struct net_dev
 			break;
 	}
 	dev_put(tx.dev);
+	skb = tx.skb; /* handlers are allowed to change skb */
 
 	if (res == TXRX_DROP) {
 		I802_DEBUG_INC(local->tx_handlers_drop);

