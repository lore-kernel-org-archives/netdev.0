From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 4/7] [DCCP]: Introduce dccp_rx_hist_find_entry
Date: Thu, 24 Aug 2006 15:23:17 +1200
Message-ID: <200608241523.17715.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:1574 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030235AbWHXDXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:23:30 -0400
Received: by py-out-1112.google.com with SMTP id t32so587590pyc
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 20:23:29 -0700 (PDT)
To: Andrea Bittau <a.bittau@cs.ucl.ac.uk>,
	David Miller <davem@davemloft.net>,
	Arnaldo de Melo <arnaldo.melo@gmail.com>,
	"DCCP (vger)" <dccp@vger.kernel.org>,
	"netdev, " <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a new function dccp_rx_hist_find_entry.

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 7b6b03e..1c68182 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -365,6 +365,25 @@ struct dccp_tx_hist_entry *
 
 EXPORT_SYMBOL_GPL(dccp_tx_hist_find_entry);
 
+int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq, 
+   u8 *ccval)
+{
+	struct dccp_rx_hist_entry *packet = NULL, *entry;
+
+	list_for_each_entry(entry, list, dccphrx_node)
+		if (entry->dccphrx_seqno == seq) {
+			packet = entry;
+			break;
+		}
+
+	if (packet)
+		*ccval = packet->dccphrx_ccval;
+
+	return packet != NULL;
+}
+
+EXPORT_SYMBOL_GPL(dccp_rx_hist_find_entry);
+
 void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
 			      struct list_head *list,
 			      struct dccp_tx_hist_entry *packet)
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 27c4309..aea9c5d 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -106,6 +106,8 @@ static inline void dccp_tx_hist_entry_de
 extern struct dccp_tx_hist_entry *
 			dccp_tx_hist_find_entry(const struct list_head *list,
 						const u64 seq);
+extern int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
+   u8 *ccval);
 
 static inline void dccp_tx_hist_add_entry(struct list_head *list,
 					  struct dccp_tx_hist_entry *entry)
