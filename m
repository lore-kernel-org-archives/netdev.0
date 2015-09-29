From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 00/14] tcp: listener refactoring preparations
Date: Tue, 29 Sep 2015 07:42:38 -0700
Message-ID: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36517 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756521AbbI2OnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:43:03 -0400
Received: by pablk4 with SMTP id lk4so8019847pab.3
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:43:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series makes changes to TCP/DCCP stacks so that
we can switch listener code to lockless mode.

This is done by marking const the listener socket in all
appropriate paths.

FastOpen code had to be changed to not dynamically allocate
a very small structure to make code simpler for following changes.

Eric Dumazet (14):
  tcp/dccp: constify send_synack and send_reset socket argument
  tcp: remove unused len argument from tcp_rcv_state_process()
  tcp: remove tcp_rcv_state_process() tcp_hdr argument
  dccp: use inet6_csk_route_req() helper
  inet: constify inet_csk_route_child_sock() socket argument
  inet: constify __inet_inherit_port() sock argument
  net: constify sk_gfp_atomic() sock argument
  dccp: constify dccp_create_openreq_child() sock argument
  tcp: constify tcp_create_openreq_child() socket argument
  tcp/dccp: constify syn_recv_sock() method sock argument
  tcp: cookie_init_sequence() cleanups
  tcp: constify tcp_v{4|6}_route_req() sock argument
  tcp: constify tcp_syn_flood_action() socket argument
  tcp: prepare fastopen code for upcoming listener changes

 include/linux/tcp.h                 | 22 ++++------------------
 include/net/inet6_connection_sock.h |  2 +-
 include/net/inet_connection_sock.h  |  5 +++--
 include/net/inet_hashtables.h       |  2 +-
 include/net/request_sock.h          | 16 ++++++----------
 include/net/sock.h                  |  2 +-
 include/net/tcp.h                   | 28 ++++++++++++++--------------
 net/core/request_sock.c             |  9 ++++++++-
 net/dccp/dccp.h                     |  6 +++---
 net/dccp/ipv4.c                     |  5 +++--
 net/dccp/ipv6.c                     | 24 +++++++-----------------
 net/dccp/minisocks.c                |  4 ++--
 net/ipv4/af_inet.c                  | 10 +++-------
 net/ipv4/inet_connection_sock.c     | 19 +++++++++----------
 net/ipv4/inet_hashtables.c          |  2 +-
 net/ipv4/syncookies.c               |  6 +-----
 net/ipv4/tcp.c                      | 14 ++------------
 net/ipv4/tcp_fastopen.c             | 10 +++++-----
 net/ipv4/tcp_input.c                | 17 +++++++++--------
 net/ipv4/tcp_ipv4.c                 | 13 +++++++------
 net/ipv4/tcp_minisocks.c            |  7 ++++---
 net/ipv6/inet6_connection_sock.c    |  8 +++++---
 net/ipv6/syncookies.c               |  5 +----
 net/ipv6/tcp_ipv6.c                 | 33 ++++++++++++++++++---------------
 24 files changed, 118 insertions(+), 151 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
