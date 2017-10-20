From: Song Liu <songliubraving@fb.com>
Subject: [PATCH net-next 2/6] tcp: mark trace event arguments sk and skb as const
Date: Fri, 20 Oct 2017 14:20:42 -0700
Message-ID: <20171020212046.577888-3-songliubraving@fb.com>
References: <20171020212046.577888-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexei.starovoitov@gmail.com>, <liu.song.a23@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44054 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752565AbdJTVU7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:20:59 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v9KLIatm014114
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:20:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2dqjgn19d6-7
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:20:58 -0700
In-Reply-To: <20171020212046.577888-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some functions that we plan to add trace points require const sk
and/or skb. So we mark these fields as const in the tracepoint.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/trace/events/tcp.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index 14b0a708..2b6fe72 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -17,13 +17,13 @@
  */
 DECLARE_EVENT_CLASS(tcp_event_sk_skb,
 
-	TP_PROTO(struct sock *sk, struct sk_buff *skb),
+	TP_PROTO(const struct sock *sk, const struct sk_buff *skb),
 
 	TP_ARGS(sk, skb),
 
 	TP_STRUCT__entry(
-		__field(void *, skbaddr)
-		__field(void *, skaddr)
+		__field(const void *, skbaddr)
+		__field(const void *, skaddr)
 		__field(__u16, sport)
 		__field(__u16, dport)
 		__array(__u8, saddr, 4)
@@ -72,7 +72,7 @@ DECLARE_EVENT_CLASS(tcp_event_sk_skb,
 
 DEFINE_EVENT(tcp_event_sk_skb, tcp_retransmit_skb,
 
-	TP_PROTO(struct sock *sk, struct sk_buff *skb),
+	TP_PROTO(const struct sock *sk, const struct sk_buff *skb),
 
 	TP_ARGS(sk, skb)
 );
-- 
2.9.5
