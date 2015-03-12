From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 0/8] inet: tcp listener refactoring, part 8
Date: Thu, 12 Mar 2015 16:44:02 -0700
Message-ID: <1426203850-11034-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:34116 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbbCLXo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 19:44:27 -0400
Received: by igqa13 with SMTP id a13so574229igq.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 16:44:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches prepare request socks being hashed into general ehash
table : We declare 3 aliases (ireq_state, ireq_refcnt, ireq_family)

Note that refcnt is not yet handled, this will be done later.


Eric Dumazet (8):
  ipv6: add missing ireq_net & ir_cookie initializations
  inet: add TCP_NEW_SYN_RECV state
  inet: add ireq_state field to inet_request_sock
  inet: add rsk_refcnt/ireq_refcnt to request socks
  net: add req_prot_cleanup() & req_prot_init() helpers
  inet: prepare sock_edemux() & sock_gen_put() for new SYN_RECV state
  inet: get_openreq4() & get_openreq6() do not need listener
  inet: introduce ireq_family

 include/net/inet_sock.h    |  6 ++++
 include/net/request_sock.h | 13 +++++++++
 include/net/sock.h         |  2 +-
 include/net/tcp_states.h   |  4 ++-
 net/core/sock.c            | 71 ++++++++++++++++++++++++++++------------------
 net/dccp/ipv4.c            |  2 +-
 net/dccp/ipv6.c            |  2 ++
 net/ipv4/inet_diag.c       |  5 ++--
 net/ipv4/inet_hashtables.c |  2 ++
 net/ipv4/syncookies.c      |  1 +
 net/ipv4/tcp_input.c       |  1 -
 net/ipv4/tcp_ipv4.c        |  9 +++---
 net/ipv6/syncookies.c      |  2 ++
 net/ipv6/tcp_ipv6.c        |  5 ++--
 14 files changed, 84 insertions(+), 41 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
