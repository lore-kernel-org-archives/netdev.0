From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 00/17] net: snmp: update SNMP methods
Date: Wed, 27 Apr 2016 16:44:26 -0700
Message-ID: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35338 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbcD0Xos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:44:48 -0400
Received: by mail-pa0-f43.google.com with SMTP id iv1so25177303pac.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:44:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the old days (before linux-3.0), SNMP counters were duplicated,
one set for user context, and anther one for BH context.

After commit 8f0ea0fe3a03 ("snmp: reduce percpu needs by 50%")
we have a single copy, and what really matters is preemption being
enabled or disabled, since we use this_cpu_inc() or __this_cpu_inc()
respectively.

This patch series kills the obsolete STATS_USER() helpers,
and rename all XXX_BH() helpers to __XXX() ones, to more
closely match conventions used to update per cpu variables.

This is probably going to hurt maintainers job for a while,
since cherry-picks will not be clean, but this had to be
cleaned at one point. I am so sorry guys.

Eric Dumazet (17):
  net: snmp: kill various STATS_USER() helpers
  dccp: rename DCCP_INC_STATS_BH()
  net: rename ICMP_INC_STATS_BH()
  net: udp: rename UDP_INC_STATS_BH()
  net: xfrm: kill XFRM_INC_STATS_BH()
  net: tcp: rename TCP_INC_STATS_BH
  net: icmp: rename ICMPMSGIN_INC_STATS_BH()
  net: sctp: rename SCTP_INC_STATS_BH()
  net: rename IP_INC_STATS_BH()
  net: rename ICMP6_INC_STATS_BH()
  net: rename IP_ADD_STATS_BH()
  net: rename IP_UPD_PO_STATS_BH()
  net: rename NET_{ADD|INC}_STATS_BH()
  ipv6: rename IP6_INC_STATS_BH()
  ipv6: rename IP6_UPD_PO_STATS_BH()
  ipv6: kill ICMP6MSGIN_INC_STATS_BH()
  net: snmp: kill STATS_BH macros

 include/net/icmp.h              |   4 +-
 include/net/ip.h                |  12 ++---
 include/net/ipv6.h              |  48 +++++++++---------
 include/net/sctp/sctp.h         |   7 ++-
 include/net/snmp.h              |  44 ++++++----------
 include/net/tcp.h               |  15 +++---
 include/net/udp.h               |  34 ++++++-------
 include/net/xfrm.h              |   4 --
 net/bridge/br_netfilter_hooks.c |   6 +--
 net/bridge/br_netfilter_ipv6.c  |  10 ++--
 net/core/dev.c                  |   4 +-
 net/dccp/dccp.h                 |   6 +--
 net/dccp/input.c                |   2 +-
 net/dccp/ipv4.c                 |  24 ++++-----
 net/dccp/ipv6.c                 |  24 ++++-----
 net/dccp/minisocks.c            |   2 +-
 net/dccp/options.c              |   2 +-
 net/dccp/timer.c                |   8 +--
 net/ipv4/arp.c                  |   2 +-
 net/ipv4/icmp.c                 |  18 +++----
 net/ipv4/inet_connection_sock.c |   4 +-
 net/ipv4/inet_hashtables.c      |   2 +-
 net/ipv4/inet_timewait_sock.c   |   4 +-
 net/ipv4/ip_forward.c           |   6 +--
 net/ipv4/ip_fragment.c          |  14 +++---
 net/ipv4/ip_input.c             |  34 ++++++-------
 net/ipv4/route.c                |   6 +--
 net/ipv4/syncookies.c           |   4 +-
 net/ipv4/tcp.c                  |  18 +++----
 net/ipv4/tcp_cdg.c              |  20 ++++----
 net/ipv4/tcp_cubic.c            |  20 ++++----
 net/ipv4/tcp_fastopen.c         |  14 +++---
 net/ipv4/tcp_input.c            | 108 +++++++++++++++++++++-------------------
 net/ipv4/tcp_ipv4.c             |  40 +++++++--------
 net/ipv4/tcp_minisocks.c        |  14 +++---
 net/ipv4/tcp_output.c           |  18 +++----
 net/ipv4/tcp_recovery.c         |   4 +-
 net/ipv4/tcp_timer.c            |  22 ++++----
 net/ipv4/udp.c                  |  72 +++++++++++++--------------
 net/ipv6/exthdrs.c              |  66 ++++++++++++------------
 net/ipv6/icmp.c                 |  12 ++---
 net/ipv6/inet6_hashtables.c     |   2 +-
 net/ipv6/ip6_input.c            |  32 ++++++------
 net/ipv6/ip6_output.c           |  34 ++++++-------
 net/ipv6/ip6mr.c                |   8 +--
 net/ipv6/reassembly.c           |  32 ++++++------
 net/ipv6/syncookies.c           |   4 +-
 net/ipv6/tcp_ipv6.c             |  34 ++++++-------
 net/ipv6/udp.c                  |  91 +++++++++++++++++----------------
 net/rxrpc/ar-input.c            |   4 +-
 net/sctp/chunk.c                |   2 +-
 net/sctp/input.c                |  16 +++---
 net/sctp/ipv6.c                 |   2 +-
 net/sunrpc/xprtsock.c           |   4 +-
 54 files changed, 512 insertions(+), 531 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
