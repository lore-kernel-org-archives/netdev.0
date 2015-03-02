From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 11/14] dccp: reduce size of dccp_skb_cb to 40 bytes
Date: Mon,  2 Mar 2015 18:40:25 +0100
Message-ID: <1425318028-26531-12-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, dccp@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54119 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754687AbbCBRkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:49 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... to eventually reduce skb->cb size.

Cc: dccp@vger.kernel.org
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/dccp/dccp.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 520c566..e8a981b 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -343,11 +343,11 @@ static inline int dccp_bad_service_code(const struct sock *sk,
 /**
  * dccp_skb_cb  -  DCCP per-packet control information
  * @dccpd_seq: sequence number
+ * @dccpd_opt_len: total length of all options (5.8) in the packet
  * @dccpd_ack_seq: acknowledgment number subheader field value
  * @dccpd_type: one of %dccp_pkt_type (or unknown)
  * @dccpd_ccval: CCVal field (5.1), see e.g. RFC 4342, 8.1
  * @dccpd_reset_code: one of %dccp_reset_codes
- * @dccpd_opt_len: total length of all options (5.8) in the packet
  *
  * This is used for transmission as well as for reception.
  */
@@ -358,13 +358,13 @@ struct dccp_skb_cb {
 		struct inet6_skb_parm	h6;
 #endif
 	} header;
-	__u64 dccpd_seq;
-	__u64 dccpd_ack_seq;
 
-	__u8  dccpd_type:4;
-	__u8  dccpd_ccval:4;
-	__u8  dccpd_reset_code;
-	__u16 dccpd_opt_len;
+	__u64 dccpd_seq:48,
+	      dccpd_opt_len:16;
+	__u64 dccpd_ack_seq:50,
+	      dccpd_type:4,
+	      dccpd_ccval:4,
+	      dccpd_reset_code:4;
 };
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
-- 
2.0.5
