From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH v2 net-next 0/3] tcp: add NV congestion control
Date: Tue, 21 Jul 2015 21:21:33 -0700
Message-ID: <1437538896-1330704-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:28727 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751743AbbGVEVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 00:21:45 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6M4JtfQ006639
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 21:21:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vt2y686fa-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 21:21:44 -0700
Received: from facebook.com (2401:db00:20:a00f:face:0:16:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 27cf5f0a302911e5bc400002c992ebde-823056b0 for <netdev@vger.kernel.org>;	Tue,
 21 Jul 2015 21:21:42 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for NV congestion control.

The first patch replaces two arguments in the pkts_acked() function
of the congestion control modules with a struct, making it easier to
add more parameters later without modifying the existing congestion
control modules.

The second patch adds the number of bytes in_flight when a packet is sent
to the tcp_skb_cb without increasing its size.

The third patch adds NV congestion control support.

[RFC PATCH v2 net-next 1/3] tcp: replace cnt & rtt with struct in pkts_acked()
[RFC PATCH v2 net-next 2/3] tcp: add in_flight to tcp_skb_cb
[RFC PATCH v2 net-next 3/3] tcp: add NV congestion control

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

 include/net/tcp.h          |  21 ++-
 net/ipv4/Kconfig           |  16 ++
 net/ipv4/Makefile          |   1 +
 net/ipv4/sysctl_net_ipv4.c |   9 +
 net/ipv4/tcp_bic.c         |   6 +-
 net/ipv4/tcp_cdg.c         |  14 +-
 net/ipv4/tcp_cubic.c       |   6 +-
 net/ipv4/tcp_htcp.c        |  10 +-
 net/ipv4/tcp_illinois.c    |  20 +-
 net/ipv4/tcp_input.c       |  12 +-
 net/ipv4/tcp_lp.c          |   6 +-
 net/ipv4/tcp_nv.c          | 479 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c      |   4 +-
 net/ipv4/tcp_vegas.c       |   6 +-
 net/ipv4/tcp_vegas.h       |   2 +-
 net/ipv4/tcp_veno.c        |   6 +-
 net/ipv4/tcp_westwood.c    |   6 +-
 net/ipv4/tcp_yeah.c        |   6 +-
 18 files changed, 579 insertions(+), 51 deletions(-)
