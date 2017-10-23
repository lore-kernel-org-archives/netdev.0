From: Song Liu <songliubraving@fb.com>
Subject: [PATCH v2 net-next 1/6] tcp: add trace event class tcp_event_sk_skb
Date: Mon, 23 Oct 2017 09:20:22 -0700
Message-ID: <20171023162027.2880430-2-songliubraving@fb.com>
References: <20171023162027.2880430-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexei.starovoitov@gmail.com>, <liu.song.a23@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55504 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751422AbdJWQU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:20:57 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v9NGIqvw017307
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:20:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2ds42422jp-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:20:56 -0700
In-Reply-To: <20171023162027.2880430-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce event class tcp_event_sk_skb for tcp tracepoints that
have arguments sk and skb.

Existing tracepoint trace_tcp_retransmit_skb() falls into this class.
This patch rewrites the definition of trace_tcp_retransmit_skb() with
tcp_event_sk_skb.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/trace/events/tcp.h | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index c3220d9..14b0a708 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -9,7 +9,13 @@
 #include <linux/tracepoint.h>
 #include <net/ipv6.h>
 
-TRACE_EVENT(tcp_retransmit_skb,
+/*
+ * tcp event with arguments sk and skb
+ *
+ * Note: this class requires a valid sk pointer; while skb pointer could
+ *       be NULL.
+ */
+DECLARE_EVENT_CLASS(tcp_event_sk_skb,
 
 	TP_PROTO(struct sock *sk, struct sk_buff *skb),
 
@@ -64,6 +70,13 @@ TRACE_EVENT(tcp_retransmit_skb,
 		  __entry->saddr_v6, __entry->daddr_v6)
 );
 
+DEFINE_EVENT(tcp_event_sk_skb, tcp_retransmit_skb,
+
+	TP_PROTO(struct sock *sk, struct sk_buff *skb),
+
+	TP_ARGS(sk, skb)
+);
+
 #endif /* _TRACE_TCP_H */
 
 /* This part must be outside protection */
-- 
2.9.5
