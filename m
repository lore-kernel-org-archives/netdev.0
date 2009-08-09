From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: dccp-test-tree [PATCH 8/10] ccid-2: Ack Vector ECN support
Date: Sun,  9 Aug 2009 21:48:45 +0200
Message-ID: <1249847327-6792-9-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_test_tree_sending_ecn_for_review>
 <1249847327-6792-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-6-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-7-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-8-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54854 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752640AbZHITst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 15:48:49 -0400
In-Reply-To: <1249847327-6792-8-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds Ack Vector support for registering ECN packets marked as
congestion-experienced (CE), and a FIXME to look after the Ack
Vector Nonce Sum (RFC 4340, 12.2 and RFC 3450, 3.).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -250,6 +250,16 @@ void dccp_ackvec_input(struct dccp_ackvec *av, struct sk_buff *skb)
 	u64 seqno = DCCP_SKB_CB(skb)->dccpd_seq;
 	enum dccp_ackvec_states state = DCCPAV_RECEIVED;
 
+	if (DCCP_SKB_CB(skb)->dccpd_ecn == INET_ECN_CE)
+		state = DCCPAV_ECN_MARKED;
+	else if (DCCP_SKB_CB(skb)->dccpd_ecn == INET_ECN_ECT_1)
+		/*
+		 * FIXME: As long as we get ECT(0), the nonce sum is 0 as per
+		 * RFC 3540, sec. 3. Supporting ECT(1) requires more work, as
+		 * e.g. older Ack Vector cells must then be summed over again.
+		 */
+		DCCP_WARN("Ack Vector Nonce sum does not yet support ECT(1)\n");
+
 	if (dccp_ackvec_is_empty(av)) {
 		dccp_ackvec_add_new(av, 1, seqno, state);
 		av->av_tail_ackno = seqno;
-- 
1.6.0.rc2

