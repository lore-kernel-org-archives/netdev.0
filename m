From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH v4 net-next 0/4] tcp: add NV congestion control
Date: Fri, 24 Jul 2015 19:47:02 -0700
Message-ID: <1437792426-1724090-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34362 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030178AbbGYCrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 22:47:19 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6P2iqoE015055
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 19:47:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vux8krey0-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 19:47:18 -0700
Received: from facebook.com (2401:db00:20:a00f:face:0:16:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 7575cec4327711e5939724be0595f910-e43f12b0 for <netdev@vger.kernel.org>;	Fri,
 24 Jul 2015 19:47:15 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for NV congestion control.

The first patch replaces two arguments with a struct in pkts_acked()
The second patch is a refactor of tcp_skb_cb
The third patch adds in_flight to tcp_skb_cb's tx section
The fourth patch adds NV congestion control support.

[RFC PATCH v4 net-next 1/4] tcp: replace cnt & rtt with struct in pkts_acked()
[RFC PATCH v4 net-next 2/4] tcp: refactor struct tcp_skb_cb
[RFC PATCH v4 net-next 3/4] tcp: add in_flight to tcp_skb_cb
[RFC PATCH v4 net-next 4/4] tcp: add NV congestion control

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

include/net/tcp.h       |  20 ++-
net/ipv4/Kconfig        |  16 ++
net/ipv4/Makefile       |   1 +
net/ipv4/tcp_bic.c      |   6 +-
net/ipv4/tcp_cdg.c      |  14 +-
net/ipv4/tcp_cubic.c    |   6 +-
net/ipv4/tcp_htcp.c     |  10 +-
net/ipv4/tcp_illinois.c |  20 +--
net/ipv4/tcp_input.c    |  10 +-
net/ipv4/tcp_lp.c       |   6 +-
net/ipv4/tcp_nv.c       | 479 ++++++++++++++++++++++++++++++++++++++++++++++++++++
net/ipv4/tcp_output.c   |   4 +-
net/ipv4/tcp_vegas.c    |   6 +-
net/ipv4/tcp_vegas.h    |   2 +-
net/ipv4/tcp_veno.c     |   6 +-
net/ipv4/tcp_westwood.c |   6 +-
net/ipv4/tcp_yeah.c     |   6 +-
17 files changed, 567 insertions(+), 51 deletions(-)
