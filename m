From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 5/5] dccp: Cleanup routines for feature negotiation
Date: Wed, 5 Nov 2008 07:54:21 +0100
Message-ID: <20081105065421.GG3482@gerrit.erg.abdn.ac.uk>
References: <20081005.091334.208715265.davem@davemloft.net> <1223312049-25967-1-git-send-email-gerrit@erg.abdn.ac.uk> <1223312049-25967-2-git-send-email-gerrit@erg.abdn.ac.uk> <1223312049-25967-3-git-send-email-gerrit@erg.abdn.ac.uk> <1223312049-25967-4-git-send-email-gerrit@erg.abdn.ac.uk> <1223312049-25967-5-git-send-email-gerrit@erg.abdn.ac.uk> <20081011073200.GF9205@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:39031 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752063AbYKEGye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 01:54:34 -0500
Content-Disposition: inline
In-Reply-To: <20081011073200.GF9205@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This inserts the required de-allocation routines for memory allocated by
feature negotiation in the socket destructors, replacing dccp_feat_clean()
in one instance.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ipv4.c  |    1 +
 net/dccp/ipv6.c  |    1 +
 net/dccp/proto.c |    2 +-
 3 files changed, 3 insertions(+), 1 deletions(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -545,6 +545,7 @@ out:
 
 static void dccp_v4_reqsk_destructor(struct request_sock *req)
 {
+	dccp_feat_list_purge(&dccp_rsk(req)->dreq_featneg);
 	kfree(inet_rsk(req)->opt);
 }
 
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -302,6 +302,7 @@ done:
 
 static void dccp_v6_reqsk_destructor(struct request_sock *req)
 {
+	dccp_feat_list_purge(&dccp_rsk(req)->dreq_featneg);
 	if (inet6_rsk(req)->pktopts != NULL)
 		kfree_skb(inet6_rsk(req)->pktopts);
 }
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -268,7 +268,7 @@ void dccp_destroy_sock(struct sock *sk)
 	dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
 
 	/* clean up feature negotiation state */
-	dccp_feat_clean(dmsk);
+	dccp_feat_list_purge(&dp->dccps_featneg);
 }
 
 EXPORT_SYMBOL_GPL(dccp_destroy_sock);

