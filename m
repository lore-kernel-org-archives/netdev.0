From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 3/7] [TFRC]: Rename tfrc_tx_hist to tfrc_tx_hist_slab, for consistency
Date: Thu,  6 Dec 2007 19:02:50 -0200
Message-ID: <1196974974-31531-4-git-send-email-acme@redhat.com>
References: <1196974974-31531-1-git-send-email-acme@redhat.com>
 <1196974974-31531-2-git-send-email-acme@redhat.com>
 <1196974974-31531-3-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:59571 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbXLFVGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 16:06:13 -0500
Received: by an-out-0708.google.com with SMTP id d31so98173and
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2007 13:06:11 -0800 (PST)
In-Reply-To: <1196974974-31531-3-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/lib/packet_history.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 1d4d6ee..b628714 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -53,7 +53,7 @@ struct tfrc_tx_hist_entry {
 /*
  * Transmitter History Routines
  */
-static struct kmem_cache *tfrc_tx_hist;
+static struct kmem_cache *tfrc_tx_hist_slab;
 
 static struct tfrc_tx_hist_entry *
 	tfrc_tx_hist_find_entry(struct tfrc_tx_hist_entry *head, u64 seqno)
@@ -66,7 +66,7 @@ static struct tfrc_tx_hist_entry *
 
 int tfrc_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno)
 {
-	struct tfrc_tx_hist_entry *entry = kmem_cache_alloc(tfrc_tx_hist, gfp_any());
+	struct tfrc_tx_hist_entry *entry = kmem_cache_alloc(tfrc_tx_hist_slab, gfp_any());
 
 	if (entry == NULL)
 		return -ENOBUFS;
@@ -85,7 +85,7 @@ void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp)
 	while (head != NULL) {
 		struct tfrc_tx_hist_entry *next = head->next;
 
-		kmem_cache_free(tfrc_tx_hist, head);
+		kmem_cache_free(tfrc_tx_hist_slab, head);
 		head = next;
 	}
 
@@ -278,17 +278,17 @@ EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
 
 __init int packet_history_init(void)
 {
-	tfrc_tx_hist = kmem_cache_create("tfrc_tx_hist",
-					 sizeof(struct tfrc_tx_hist_entry), 0,
-					 SLAB_HWCACHE_ALIGN, NULL);
+	tfrc_tx_hist_slab = kmem_cache_create("tfrc_tx_hist",
+					      sizeof(struct tfrc_tx_hist_entry), 0,
+					      SLAB_HWCACHE_ALIGN, NULL);
 
-	return tfrc_tx_hist == NULL ? -ENOBUFS : 0;
+	return tfrc_tx_hist_slab == NULL ? -ENOBUFS : 0;
 }
 
 void packet_history_exit(void)
 {
-	if (tfrc_tx_hist != NULL) {
-		kmem_cache_destroy(tfrc_tx_hist);
-		tfrc_tx_hist = NULL;
+	if (tfrc_tx_hist_slab != NULL) {
+		kmem_cache_destroy(tfrc_tx_hist_slab);
+		tfrc_tx_hist_slab = NULL;
 	}
 }
-- 
1.5.3.4

