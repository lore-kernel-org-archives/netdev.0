From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH v5 net-next 0/4] tcp: add NV congestion control
Date: Tue, 4 Aug 2015 18:39:04 -0700
Message-ID: <1438738748-1756255-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33022 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751070AbbHEBjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 21:39:14 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t751a3Oe012873
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2015 18:39:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1w368dgf7h-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 18:39:13 -0700
Received: from facebook.com (2401:db00:20:a00f:face:0:16:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 c59975603b1211e59c190002c991e86a-657f92b0 for <netdev@vger.kernel.org>;	Tue,
 04 Aug 2015 18:39:11 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for NV congestion control.

Changes from v4: passing structure as constant in pkts_acked()

Consists of the following patches:

[RFC PATCH v5 net-next 1/4] tcp: replace cnt & rtt with struct in
[RFC PATCH v5 net-next 2/4] tcp:  refactor struct tcp_skb_cb
[RFC PATCH v5 net-next 3/4] tcp: add in_flight to tcp_skb_cb
[RFC PATCH v5 net-next 4/4] tcp: add NV congestion control

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
net/ipv4/tcp_veno.c     |   7 +-
net/ipv4/tcp_westwood.c |   7 +-
net/ipv4/tcp_yeah.c     |   7 +-
17 files changed, 570 insertions(+), 51 deletions(-)
