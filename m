From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/5] tcp: lockless listener fixes and improvement
Date: Sun,  4 Oct 2015 21:08:06 -0700
Message-ID: <1444018091-21987-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33577 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbbJEEIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 00:08:17 -0400
Received: by pacex6 with SMTP id ex6so163660731pac.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 21:08:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes issues with TCP FastOpen vs lockless listeners,
and SYNACK being attached to request sockets.

Then, last patch brings performance improvement for
syncookies generation and validation.

Tested under a 4.3 Mpps SYNFLOOD attack, new perf profile looks
like :
    12.11%  [kernel]  [k] sha_transform
     5.83%  [kernel]  [k] tcp_conn_request
     4.59%  [kernel]  [k] __inet_lookup_listener
     4.11%  [kernel]  [k] ipt_do_table
     3.91%  [kernel]  [k] tcp_make_synack
     3.05%  [kernel]  [k] fib_table_lookup
     2.74%  [kernel]  [k] sock_wfree
     2.66%  [kernel]  [k] memcpy_erms
     2.12%  [kernel]  [k] tcp_v4_rcv

Eric Dumazet (5):
  tcp: fix fastopen races vs lockless listener
  inet: ip_skb_dst_mtu() should use sk_fullsock()
  ipv6: inet6_sk() should use sk_fullsock()
  net: use sk_fullsock() in __netdev_pick_tx()
  tcp: avoid two atomic ops for syncookies

 include/linux/ipv6.h       |  4 ++--
 include/net/inet_sock.h    |  3 ++-
 include/net/ip.h           |  9 ++++++---
 include/net/request_sock.h | 12 +++++++++---
 net/core/dev.c             |  1 +
 net/dccp/ipv4.c            |  2 +-
 net/dccp/ipv6.c            |  2 +-
 net/ipv4/syncookies.c      |  2 +-
 net/ipv4/tcp_fastopen.c    | 26 +++++++-------------------
 net/ipv4/tcp_input.c       | 14 ++++++++++----
 net/ipv6/syncookies.c      |  2 +-
 11 files changed, 41 insertions(+), 36 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
