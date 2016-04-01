From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net 0/4] ip6: datagram: Update dst cache of a connected datagram sk during pmtu update
Date: Fri, 1 Apr 2016 15:56:27 -0700
Message-ID: <1459551391-69969-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:7612 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754341AbcDAW5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 18:57:32 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u31MvG2J017449
	for <netdev@vger.kernel.org>; Fri, 1 Apr 2016 15:57:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 221x2w9197-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 15:57:31 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 1cf6e3e4f85d11e58ecd0002c99293a0-73fed3f0 for <netdev@vger.kernel.org>;	Fri,
 01 Apr 2016 15:57:30 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a case in connected UDP socket such that
getsockopt(IPV6_MTU) will return a stale MTU value. The reproducible
sequence could be the following:
1. Create a connected UDP socket
2. Send some datagrams out
3. Receive a ICMPV6_PKT_TOOBIG
4. No new outgoing datagrams to trigger the sk_dst_check()
   logic to update the sk->sk_dst_cache.
5. getsockopt(IPV6_MTU) returns the mtu from the invalid
   sk->sk_dst_cache instead of the newly created RTF_CACHE clone.

Patch 1 and 2 are the prep work.
Patch 3 and 4 are the fixes.
