From: Song Liu <songliubraving@fb.com>
Subject: [PATCH net-next 5/6] tcp: add tracepoint trace_tcp_destroy_sock
Date: Fri, 20 Oct 2017 14:20:45 -0700
Message-ID: <20171020212046.577888-6-songliubraving@fb.com>
References: <20171020212046.577888-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexei.starovoitov@gmail.com>, <liu.song.a23@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38842 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752340AbdJTVU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 17:20:57 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9KLF0nh000524
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:20:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dqnq48pej-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 14:20:56 -0700
In-Reply-To: <20171020212046.577888-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds trace event trace_tcp_destroy_sock.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/trace/events/tcp.h | 7 +++++++
 net/ipv4/tcp_ipv4.c        | 2 ++
 2 files changed, 9 insertions(+)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index c83c711..1724c12 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -154,6 +154,13 @@ DEFINE_EVENT(tcp_event_sk, tcp_receive_reset,
 	TP_ARGS(sk)
 );
 
+DEFINE_EVENT(tcp_event_sk, tcp_destroy_sock,
+
+	TP_PROTO(const struct sock *sk),
+
+	TP_ARGS(sk)
+);
+
 #endif /* _TRACE_TCP_H */
 
 /* This part must be outside protection */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index aa99d9d..736753a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1865,6 +1865,8 @@ void tcp_v4_destroy_sock(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	trace_tcp_destroy_sock(sk);
+
 	tcp_clear_xmit_timers(sk);
 
 	tcp_cleanup_congestion_control(sk);
-- 
2.9.5
