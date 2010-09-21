From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/5] dccp: Replace magic CCID-specific numbers by symbolic constants
Date: Tue, 21 Sep 2010 12:28:55 +0200
Message-ID: <1285064938-5933-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <miscellaneous_dccp_ccid_fixes>
 <1285064938-5933-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1285064938-5933-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:64858 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752393Ab0IUK3N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 06:29:13 -0400
In-Reply-To: <1285064938-5933-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The constants DCCPO_{MIN,MAX}_CCID_SPECIFIC are nowhere used in the code, but
instead for the CCID-specific options numbers are used.

This patch unifies the use of CCID-specific option numbers, by adding symbolic
names reflecting the definitions in RFC 4340, 10.3.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    6 ++++--
 net/dccp/options.c   |   13 +++----------
 2 files changed, 7 insertions(+), 12 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -165,8 +165,10 @@ enum {
 	DCCPO_TIMESTAMP_ECHO = 42,
 	DCCPO_ELAPSED_TIME = 43,
 	DCCPO_MAX = 45,
-	DCCPO_MIN_CCID_SPECIFIC = 128,
-	DCCPO_MAX_CCID_SPECIFIC = 255,
+	DCCPO_MIN_RX_CCID_SPECIFIC = 128,	/* from sender to receiver */
+	DCCPO_MAX_RX_CCID_SPECIFIC = 191,
+	DCCPO_MIN_TX_CCID_SPECIFIC = 192,	/* from receiver to sender */
+	DCCPO_MAX_TX_CCID_SPECIFIC = 255,
 };
 /* maximum size of a single TLV-encoded DCCP option (sans type/len bytes) */
 #define DCCP_SINGLE_OPT_MAXLEN	253
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -96,18 +96,11 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		}
 
 		/*
-		 * CCID-Specific Options (from RFC 4340, sec. 10.3):
-		 *
-		 * Option numbers 128 through 191 are for options sent from the
-		 * HC-Sender to the HC-Receiver; option numbers 192 through 255
-		 * are for options sent from the HC-Receiver to	the HC-Sender.
-		 *
 		 * CCID-specific options are ignored during connection setup, as
 		 * negotiation may still be in progress (see RFC 4340, 10.3).
 		 * The same applies to Ack Vectors, as these depend on the CCID.
-		 *
 		 */
-		if (dreq != NULL && (opt >= 128 ||
+		if (dreq != NULL && (opt >= DCCPO_MIN_RX_CCID_SPECIFIC ||
 		    opt == DCCPO_ACK_VECTOR_0 || opt == DCCPO_ACK_VECTOR_1))
 			goto ignore_option;
 
@@ -226,12 +219,12 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			dccp_pr_debug("%s rx opt: ELAPSED_TIME=%d\n",
 				      dccp_role(sk), elapsed_time);
 			break;
-		case 128 ... 191:
+		case DCCPO_MIN_RX_CCID_SPECIFIC ... DCCPO_MAX_RX_CCID_SPECIFIC:
 			if (ccid_hc_rx_parse_options(dp->dccps_hc_rx_ccid, sk,
 						     pkt_type, opt, value, len))
 				goto out_invalid_option;
 			break;
-		case 192 ... 255:
+		case DCCPO_MIN_TX_CCID_SPECIFIC ... DCCPO_MAX_TX_CCID_SPECIFIC:
 			if (ccid_hc_tx_parse_options(dp->dccps_hc_tx_ccid, sk,
 						     pkt_type, opt, value, len))
 				goto out_invalid_option;
