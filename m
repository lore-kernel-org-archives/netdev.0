From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/6] tcp: better handling of memory pressure
Date: Fri, 15 May 2015 07:53:52 -0700
Message-ID: <1431701638-24451-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Jason Baron <jbaron@akamai.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:33743 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101AbbEOPCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 11:02:06 -0400
Received: by ykp9 with SMTP id 9so3220957ykp.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 08:02:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When testing commit 790ba4566c1a ("tcp: set SOCK_NOSPACE under memory
pressure") using edge triggered epoll applications, I found various
issues under memory pressure and thousands of active sockets.

This patch series is a first round to solve these issues, in send
and receive paths. There are probably other fixes needed, but
with this series, my tests now all succeed.

Eric Dumazet (6):
  net: fix sk_mem_reclaim_partial()
  tcp: rename sk_forced_wmem_schedule() to sk_forced_mem_schedule()
  tcp: introduce tcp_under_memory_pressure()
  tcp: fix behavior for epoll edge trigger
  tcp: allow one skb to be received per socket under memory pressure
  tcp: halves tcp_mem[] limits

 include/net/sock.h    |  6 +++---
 include/net/tcp.h     | 10 ++++++++++
 net/core/sock.c       |  9 +++++----
 net/ipv4/tcp.c        | 24 ++++++++++++++++++------
 net/ipv4/tcp_input.c  | 18 ++++++++++--------
 net/ipv4/tcp_output.c | 10 ++++++----
 net/ipv4/tcp_timer.c  |  2 +-
 7 files changed, 53 insertions(+), 26 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
