From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: restore formatting of macros for tcp_skb_cb sacked field
Date: Mon, 16 Apr 2012 13:08:06 -0400
Message-ID: <1334596086-22905-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f74.google.com ([209.85.213.74]:55332 "EHLO
	mail-yw0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab2DPRPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 13:15:13 -0400
Received: by yhgm50 with SMTP id m50so615599yhg.1
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2012 10:15:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b82d1bb4 inadvertendly placed unrelated new code between
TCPCB_EVER_RETRANS and TCPCB_RETRANS and the other macros that refer
to the sacked field in the struct tcp_skb_cb (probably because there
was a misleading empty line there). This commit fixes up the
formatting so that all macros related to the sacked field are adjacent
again.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/net/tcp.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f75a04d..a725f2d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -645,16 +645,17 @@ struct tcp_skb_cb {
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
 	__u32		when;		/* used to compute rtt's	*/
 	__u8		tcp_flags;	/* TCP header flags. (tcp[13])	*/
+
 	__u8		sacked;		/* State flags for SACK/FACK.	*/
 #define TCPCB_SACKED_ACKED	0x01	/* SKB ACK'd by a SACK block	*/
 #define TCPCB_SACKED_RETRANS	0x02	/* SKB retransmitted		*/
 #define TCPCB_LOST		0x04	/* SKB is lost			*/
 #define TCPCB_TAGBITS		0x07	/* All tag bits			*/
-	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
-	/* 1 byte hole */
 #define TCPCB_EVER_RETRANS	0x80	/* Ever retransmitted frame	*/
 #define TCPCB_RETRANS		(TCPCB_SACKED_RETRANS|TCPCB_EVER_RETRANS)
 
+	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
+	/* 1 byte hole */
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 };
 
-- 
1.7.7.3
