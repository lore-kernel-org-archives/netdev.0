From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 3/8] [TFRC/CCID3]: Remove now unused functions / function calls
Date: Sat,  8 Dec 2007 10:06:23 +0000
Message-ID: <11971083883685-git-send-email-gerrit@erg.abdn.ac.uk>
References: <11971083882331-git-send-email-gerrit@erg.abdn.ac.uk>
 <11971083881862-git-send-email-gerrit@erg.abdn.ac.uk>
 <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:61579 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752203AbXLHKHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2007 05:07:50 -0500
In-Reply-To: <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes two things which now have become redundant:
 1. The function tfrc_rx_hist_entry_delete() is no longer referenced anywhere.
 2. The CCID3 HC-receiver still inserted timestamps, but received timestamps
    are not parsed/referenced/used by the HC-sender, it serves no function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |    3 +--
 net/dccp/ccids/lib/packet_history.c |    5 -----
 2 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index a5246f7..60fcb31 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -750,8 +750,7 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	x_recv = htonl(hcrx->ccid3hcrx_x_recv);
 	pinv   = htonl(hcrx->ccid3hcrx_pinv);
 
-	if (dccp_insert_option_timestamp(sk, skb) ||
-	    dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
+	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
 			       &x_recv, sizeof(x_recv)))
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index af0db71..4d37396 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -183,11 +183,6 @@ void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
 
-static inline void tfrc_rx_hist_entry_delete(struct tfrc_rx_hist_entry *entry)
-{
-	kmem_cache_free(tfrc_rx_hist_slab, entry);
-}
-
 /**
  * tfrc_rx_hist_entry - return the n-th history entry after loss_start
  */
