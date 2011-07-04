From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 4/6] dccp ccid-2: move rfc 3390 function into header file
Date: Mon,  4 Jul 2011 13:01:17 -0600
Message-ID: <1309806079-21604-5-git-send-email-gerrit@erg.abdn.ac.uk>
References: <test_tree_patch_set_update_2011-07-04>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53735 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750860Ab1GDTUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 15:20:44 -0400
In-Reply-To: <test_tree_patch_set_update_2011-07-04>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves CCID-2's initial window function into the header file, since several
parts throughout the CCID-2 code need to call it (CCID-2 still uses RFC 3390).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Leandro Melo de Sales <leandro@ic.ufal.br>
---
 net/dccp/ccids/ccid2.c |    9 ---------
 net/dccp/ccids/ccid2.h |    9 +++++++++
 2 files changed, 9 insertions(+), 9 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -583,15 +583,6 @@ done:
 	dccp_ackvec_parsed_cleanup(&hc->tx_av_chunks);
 }
 
-/*
- * Convert RFC 3390 larger initial window into an equivalent number of packets.
- * This is based on the numbers specified in RFC 5681, 3.1.
- */
-static inline u32 rfc3390_bytes_to_packets(const u32 smss)
-{
-	return smss <= 1095 ? 4 : (smss > 2190 ? 2 : 3);
-}
-
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hc = ccid_priv(ccid);
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -88,6 +88,15 @@ static inline bool ccid2_cwnd_network_limited(struct ccid2_hc_tx_sock *hc)
 	return hc->tx_pipe >= hc->tx_cwnd;
 }
 
+/*
+ * Convert RFC 3390 larger initial window into an equivalent number of packets.
+ * This is based on the numbers specified in RFC 5681, 3.1.
+ */
+static inline u32 rfc3390_bytes_to_packets(const u32 smss)
+{
+	return smss <= 1095 ? 4 : (smss > 2190 ? 2 : 3);
+}
+
 struct ccid2_hc_rx_sock {
 	int	rx_data;
 };
