From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/6] inet: tcp listener refactoring, part 12
Date: Tue, 17 Mar 2015 18:32:25 -0700
Message-ID: <1426642351-26098-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:34766 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbbCRBcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 21:32:36 -0400
Received: by igqa13 with SMTP id a13so1823006igq.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 18:32:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By adding a pointer back to listener, we are preparing synack rtx
handling to no longer be governed by listener keepalive timer,
as this is the most problematic source of contention on listener
spinlock. Note that TCP FastOpen had such pointer anyway, so we
make it generic.

Eric Dumazet (6):
  inet: add sk_listener argument to inet_reqsk_alloc()
  inet: uninline inet_reqsk_alloc()
  inet: add rsk_listener field to struct request_sock
  tcp: rename struct tcp_request_sock listener
  inet: avoid fastopen lock for regular accept()
  inet: fix request sock refcounting

 include/linux/tcp.h                |  2 +-
 include/net/inet_connection_sock.h |  5 -----
 include/net/inet_sock.h            | 22 ++--------------------
 include/net/request_sock.h         | 24 +++++++++++++++++++++---
 net/core/request_sock.c            | 18 +++++++-----------
 net/dccp/ipv4.c                    |  3 +--
 net/dccp/ipv6.c                    |  3 +--
 net/ipv4/inet_connection_sock.c    | 13 +++++++------
 net/ipv4/syncookies.c              | 16 ++++++++--------
 net/ipv4/tcp_fastopen.c            |  8 ++------
 net/ipv4/tcp_input.c               | 25 ++++++++++++++++++++++---
 net/ipv6/syncookies.c              | 12 ++++++------
 12 files changed, 78 insertions(+), 73 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
