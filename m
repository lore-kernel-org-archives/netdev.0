From: Song Liu <songliubraving@fb.com>
Subject: [PATCH v2 net-next 0/6] add a set of tracepoints to tcp stack
Date: Mon, 23 Oct 2017 09:20:21 -0700
Message-ID: <20171023162027.2880430-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexei.starovoitov@gmail.com>, <liu.song.a23@gmail.com>,
        Song Liu <songliubraving@fb.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51824 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751288AbdJWQU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:20:57 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9NGI0Yu025853
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:20:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dsjgc8a8t-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:20:56 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v1:

Fix build error (with ipv6 as ko) by adding EXPORT_TRACEPOINT_SYMBOL_GPL
for trace_tcp_send_reset.

These patches add the following tracepoints to tcp stack.

tcp_send_reset
tcp_receive_reset
tcp_destroy_sock
tcp_set_state

These tracepoints can be used to track TCP state changes. Such state
changes include but are not limited to: connection establish,
connection termination, tx and rx of RST, various retransmits.

Currently, we use the following kprobes to trace these events:

int kprobe__tcp_validate_incoming
int kprobe__tcp_send_active_reset
int kprobe__tcp_v4_send_reset
int kprobe__tcp_v6_send_reset
int kprobe__tcp_v4_destroy_sock
int kprobe__tcp_set_state
int kprobe__tcp_retransmit_skb

These tracepoints will help us simplify this work.

Thanks,
Song

Song Liu (6):
  tcp: add trace event class tcp_event_sk_skb
  tcp: mark trace event arguments sk and skb as const
  tcp: add tracepoint trace_tcp_send_reset
  tcp: add tracepoint trace_tcp_receive_reset
  tcp: add tracepoint trace_tcp_destroy_sock
  tcp: add tracepoint trace_tcp_set_state()

 include/trace/events/tcp.h | 181 ++++++++++++++++++++++++++++++++++++++++++++-
 net/core/net-traces.c      |   2 +
 net/ipv4/tcp.c             |   4 +
 net/ipv4/tcp_input.c       |   3 +
 net/ipv4/tcp_ipv4.c        |   8 +-
 net/ipv4/tcp_output.c      |   5 ++
 net/ipv6/tcp_ipv6.c        |  10 ++-
 7 files changed, 206 insertions(+), 7 deletions(-)
