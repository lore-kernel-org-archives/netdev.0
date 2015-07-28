From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/2] net: Initialize sk_hash to random value and reset for failing cnxs
Date: Tue, 28 Jul 2015 16:02:04 -0700
Message-ID: <1438124526-2129341-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52359 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750943AbbG1XCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 19:02:31 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6SN0ll0005023
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 16:02:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vxj42g7ys-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 16:02:30 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 b76dcde2357c11e5a55d24be05956610-d7bf52b0 for <netdev@vger.kernel.org>;	Tue,
 28 Jul 2015 16:02:27 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set implements a common function to simply set sk_txhash to
a random number instead of going through the trouble to call flow
dissector. From dst_negative_advice we now reset the sk_txhash in hopes
of finding a better ECMP path through the network. Changing sk_txhash
affects:
  - IPv6 flow label and UDP source port which affect ECMP in the network
  - Local EMCP route selection (pending changes to use sk_txhash)

Tom Herbert (2):
  net: Set sk_txhash from a random number
  net: Recompute sk_txhash on negative routing advice

 include/net/ip.h    | 16 ----------------
 include/net/ipv6.h  | 19 -------------------
 include/net/sock.h  | 16 ++++++++++++++++
 net/ipv4/datagram.c |  2 +-
 net/ipv4/tcp_ipv4.c |  4 ++--
 net/ipv6/datagram.c |  2 +-
 net/ipv6/tcp_ipv6.c |  4 ++--
 7 files changed, 22 insertions(+), 41 deletions(-)

-- 
1.8.1
