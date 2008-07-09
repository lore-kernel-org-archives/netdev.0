From: "Adam Langley" <agl@imperialviolet.org>
Subject: [PATCH] TCP: Add seq and ack numbers to TCP_INFO
Date: Wed, 9 Jul 2008 10:23:43 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069003@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:41703 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535AbYGIR1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 13:27:44 -0400
Received: by yx-out-2324.google.com with SMTP id 8so869674yxm.1
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2008 10:27:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP: Add seq and ack numbers to TCP_INFO

No ABI breakage: Userspace specifies the size of the structure that they're
expecting, and the new fields are at the end, so existing code should function
just fine as we'll truncate the new struct tcp_info to fit.

Signed-off-by: Adam Langley <agl@imperialviolet.org>
---

 include/linux/tcp.h |    5 +++++
 net/ipv4/tcp.c      |    5 +++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 07e79bd..55094ea 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -157,6 +157,11 @@ struct tcp_info
 	__u32	tcpi_rcv_space;
 
 	__u32	tcpi_total_retrans;
+
+	__u32	tcpi_seq; /* seq number of next byte to be written to socket */
+	__u32	tcpi_ack; /* ack number of next byte to be read from socket */
+	__u32	tcpi_tseq; /* seq number of next byte to be transmitted */
+	__u32	tcpi_tack; /* ack number of next byte to be received */
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 56a133c..c56d5c3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2255,6 +2255,11 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_rcv_space = tp->rcvq_space.space;
 
 	info->tcpi_total_retrans = tp->total_retrans;
+
+	info->tcpi_seq = tp->write_seq;
+	info->tcpi_ack = tp->copied_seq;
+	info->tcpi_tseq = tp->pushed_seq;
+	info->tcpi_tack = tp->rcv_nxt;
 }
 
 EXPORT_SYMBOL_GPL(tcp_get_info);
