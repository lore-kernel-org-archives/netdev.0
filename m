From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 00/17] dccp/tcp: constify listener sock
Date: Fri, 25 Sep 2015 07:39:07 -0700
Message-ID: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35221 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932268AbbIYOjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:39:37 -0400
Received: by pacfv12 with SMTP id fv12so109566083pac.2
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:39:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another patch bomb to prepare lockless TCP/DCCP LISTEN handling. 

SYNACK retransmits are built and sent without listener socket
being locked. Soon, initial SYNACK packets will have same property.

This series makes sure we did not something wrong with this model,
by adding a const qualifier in all the paths taken from synack building
and transmit, for IPv4/IPv6 and TCP/dccp.

The only potential problem was the rewrite of ecn bits for connections
with DCTCP as congestion module, but this was a very minor one.

Eric Dumazet (17):
  tcp: constify listener socket in tcp_v[46]_init_req()
  tcp: constify tcp_openreq_init_rwin()
  inet: constify ip_route_output_flow() socket argument
  inet: constify inet_csk_route_req() socket argument
  ipv6: constify ip6_dst_lookup_{flow|tail}() sock arguments
  ipv6: constify inet6_csk_route_req() socket argument
  inet: constify ip_dont_fragment() arguments
  tcp: md5: constify tcp_md5_do_lookup() socket argument
  ip: constify ip_build_and_send_pkt() socket argument
  tcp: remove tcp_synack_options() socket argument
  tcp: remove tcp_ecn_make_synack() socket argument
  tcp: constify tcp_make_synack() socket argument
  ipv6: constify ip6_xmit() sock argument
  tcp: constify tcp_v{4|6}_send_synack() socket argument
  dccp: constify dccp_make_response() socket argument
  tcp/dccp: constify rtx_synack() and friends
  inet: constify inet_rtx_syn_ack() sock argument
---
David, to apply these patches you'll need to merge net tree into net-next
first. Thanks !

 include/net/dst.h                   |  9 ++++---
 include/net/inet6_connection_sock.h |  2 +-
 include/net/inet_connection_sock.h  |  2 +-
 include/net/ip.h                    | 10 +++++---
 include/net/ipv6.h                  |  4 +--
 include/net/request_sock.h          |  4 +--
 include/net/route.h                 |  2 +-
 include/net/tcp.h                   | 22 ++++++++--------
 net/dccp/dccp.h                     |  2 +-
 net/dccp/ipv4.c                     |  2 +-
 net/dccp/ipv6.c                     |  2 +-
 net/dccp/output.c                   | 17 ++++++++-----
 net/ipv4/inet_connection_sock.c     |  4 +--
 net/ipv4/ip_output.c                | 14 +++++-----
 net/ipv4/route.c                    |  2 +-
 net/ipv4/tcp_cong.c                 | 12 +++++++--
 net/ipv4/tcp_ipv4.c                 | 11 ++++----
 net/ipv4/tcp_minisocks.c            | 28 ++++++++++++--------
 net/ipv4/tcp_output.c               | 51 +++++++++++++++++++------------------
 net/ipv6/datagram.c                 |  2 +-
 net/ipv6/inet6_connection_sock.c    |  2 +-
 net/ipv6/ip6_output.c               | 30 +++++++++++++++-------
 net/ipv6/tcp_ipv6.c                 | 15 ++++++-----
 net/xfrm/xfrm_policy.c              |  6 ++---
 24 files changed, 149 insertions(+), 106 deletions(-)

-- 
2.6.0.rc2.230.g3dd15c0
