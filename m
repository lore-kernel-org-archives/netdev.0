From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/3] inet: tcp listener refactoring part 14
Date: Thu, 19 Mar 2015 19:04:18 -0700
Message-ID: <1426817061-21421-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:34506 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbCTCEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 22:04:25 -0400
Received: by padet14 with SMTP id et14so5950925pad.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 19:04:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, we have serious patches here.

We get rid of the central timer handling SYNACK rtx,
which is killing us under even medium SYN flood.

We still use the listener specific hash table.

This will be done in next round ;)

Eric Dumazet (3):
  inet: drop prev pointer handling in request sock
  inet: get rid of central tcp/dccp listener timer
  net: increase sk_[max_]ack_backlog

 include/net/inet6_connection_sock.h |   3 +-
 include/net/inet_connection_sock.h  |  26 +++----
 include/net/request_sock.h          |  98 ++++++++++++-------------
 include/net/sock.h                  |   4 +-
 include/net/tcp.h                   |   3 +-
 net/core/request_sock.c             |  13 ++--
 net/core/sock.c                     |   2 +-
 net/core/sysctl_net_core.c          |   2 -
 net/dccp/dccp.h                     |   3 +-
 net/dccp/ipv4.c                     |  20 +++---
 net/dccp/ipv6.c                     |  27 +++----
 net/dccp/minisocks.c                |   7 +-
 net/dccp/timer.c                    |  24 +------
 net/ipv4/inet_connection_sock.c     | 139 ++++++++++++++++++------------------
 net/ipv4/inet_diag.c                |   4 +-
 net/ipv4/syncookies.c               |   1 -
 net/ipv4/tcp_fastopen.c             |   2 +-
 net/ipv4/tcp_input.c                |   2 +-
 net/ipv4/tcp_ipv4.c                 |  26 ++++---
 net/ipv4/tcp_minisocks.c            |  10 +--
 net/ipv4/tcp_timer.c                |  12 +---
 net/ipv6/inet6_connection_sock.c    |  23 +++---
 net/ipv6/syncookies.c               |   1 -
 net/ipv6/tcp_ipv6.c                 |  22 +++---
 24 files changed, 220 insertions(+), 254 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
