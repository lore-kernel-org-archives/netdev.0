From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/5] inet: tcp listener refactoring, part 10
Date: Sun, 15 Mar 2015 21:12:11 -0700
Message-ID: <1426479136-15645-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:32840 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbCPEMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:12:19 -0400
Received: by ykp131 with SMTP id 131so5802046ykp.0
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 21:12:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are getting close to the point where request sockets will be hashed
into generic hash table. Some followups are needed for netfilter and
will be handled in next patch series.

Eric Dumazet (5):
  net: add sk_fullsock() helper
  inet: ip early demux should avoid request sockets
  inet_diag: allow sk_diag_fill() to handle request socks
  inet: factorize sock_edemux()/sock_gen_put() code
  inet: add proper refcounting to request sock

 include/net/inet_connection_sock.h |   5 ++
 include/net/inet_sock.h            |   5 ++
 include/net/request_sock.h         |  13 ++--
 include/net/sock.h                 |   9 +++
 net/core/request_sock.c            |   4 +-
 net/core/sock.c                    |  15 -----
 net/ipv4/inet_connection_sock.c    |   8 +--
 net/ipv4/inet_diag.c               | 120 ++++++++++++++++---------------------
 net/ipv4/inet_hashtables.c         |   6 ++
 net/ipv4/syncookies.c              |  10 ++--
 net/ipv4/tcp_fastopen.c            |   2 +-
 net/ipv4/tcp_ipv4.c                |   2 +-
 net/ipv6/tcp_ipv6.c                |   2 +-
 13 files changed, 99 insertions(+), 102 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
