From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 6/6] [TCP]: Reorganize struct tcp_sock to save 16 bytes on 64-bit arch
Date: Thu, 31 Jan 2008 16:31:44 -0200
Message-ID: <1201804304-28777-7-git-send-email-acme@redhat.com>
References: y
 <1201804304-28777-1-git-send-email-acme@redhat.com>
 <1201804304-28777-2-git-send-email-acme@redhat.com>
 <1201804304-28777-3-git-send-email-acme@redhat.com>
 <1201804304-28777-4-git-send-email-acme@redhat.com>
 <1201804304-28777-5-git-send-email-acme@redhat.com>
 <1201804304-28777-6-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:28022 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760157AbYAaScG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:32:06 -0500
Received: by wr-out-0506.google.com with SMTP id c48so776441wra.23
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 10:32:05 -0800 (PST)
In-Reply-To: <1201804304-28777-6-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/home/acme/git/net-2.6/net/ipv6/tcp_ipv6.c:
  struct tcp_sock  |  -16
  struct tcp6_sock |  -16
 2 structs changed

Now it is at:

/* size: 1552, cachelines: 25 */
/* paddings: 2, sum paddings: 8 */
/* last cacheline: 16 bytes */

As soon as we stop using skb_queue_list we'll get it down to 24 cachelines.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/tcp.h |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 08027f1..f48644d 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -304,7 +304,6 @@ struct tcp_sock {
 	u32	rtt_seq;	/* sequence number to update rttvar	*/
 
 	u32	packets_out;	/* Packets which are "in flight"	*/
-	u32	retrans_out;	/* Retransmitted packets out		*/
 /*
  *      Options received (usually on last packet, some only on SYN packets).
  */
@@ -332,6 +331,8 @@ struct tcp_sock {
 
 	struct tcp_sack_block recv_sack_cache[4];
 
+	u32	retrans_out;	/* Retransmitted packets out		*/
+
 	struct sk_buff *highest_sack;   /* highest skb with SACK received
 					 * (validity guaranteed only if
 					 * sacked_out > 0)
@@ -372,7 +373,6 @@ struct tcp_sock {
 
 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
-	int			linger2;
 
 	unsigned long last_synq_overflow; 
 
@@ -398,6 +398,8 @@ struct tcp_sock {
 		u32		  probe_seq_end;
 	} mtu_probe;
 
+	int			linger2;
+
 #ifdef CONFIG_TCP_MD5SIG
 /* TCP AF-Specific parts; only used by MD5 Signature support so far */
 	struct tcp_sock_af_ops	*af_specific;
-- 
1.5.3.8

