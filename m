From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 0/3] ipv4: preparation work for making ipv4 routing ecn robust
Date: Mon, 13 Jun 2016 22:47:35 +0200
Message-ID: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
Cc: ja@ssi.bg, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:46521 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161183AbcFMUrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 16:47:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably out of laziness we encoded the RTO_ONLINK flag into the
lowest ToS bit to easier pass it around in the flowi structure (we
need one less argument to do so).

This series cleans it up and uses flowi4_scope correctly from nearly
the top-level, thus removing the need to encode the RTO_ONLINK flag
into tos. This makes it later easier to verify that we correctly use
the ToS bit. Currently we are leaking one ECN bit into the routing
engine, which could make different decisions based on ECN signaling.

This is the first clean-up preparational work to later on fix the
RT_TOS macros.

My question is, if this is acceptable. Especially because it removes
the flowi4_init_output and flowi4_update_output functions and expands
them inline. I did so to easy code review with grepping and finally
not being forced to count the arguments.

Opinions before I go on? Thanks!

Hannes Frederic Sowa (3):
  ipv4: make flow functions more grepable by removing flowi4_init_output
  ipv4: make flow functions more grepable by removing
    flowi4_update_output
  ipv4: kill RTO_ONLINK, RT_CONN_FLAGS and RT_CONN_FLAGS_TOS

 drivers/net/bonding/bond_main.c |  3 +-
 drivers/net/gtp.c               |  3 +-
 drivers/net/ppp/pptp.c          |  2 +-
 drivers/net/vrf.c               |  7 ----
 include/net/flow.h              | 32 -------------------
 include/net/ip.h                |  5 ---
 include/net/route.h             | 71 +++++++++++++++++++++++++++++++----------
 net/dccp/ipv4.c                 |  5 +--
 net/ipv4/af_inet.c              |  4 +--
 net/ipv4/arp.c                  |  4 +--
 net/ipv4/datagram.c             |  5 +--
 net/ipv4/inet_connection_sock.c | 44 +++++++++++++++++--------
 net/ipv4/ip_output.c            | 23 ++++++++-----
 net/ipv4/ping.c                 | 20 +++++++++---
 net/ipv4/raw.c                  | 31 ++++++++++++------
 net/ipv4/route.c                | 50 +++++++++++++++++++----------
 net/ipv4/syncookies.c           | 19 ++++++++---
 net/ipv4/tcp_ipv4.c             |  2 +-
 net/ipv4/udp.c                  | 21 ++++++++----
 net/l2tp/l2tp_ip.c              |  3 +-
 net/netfilter/ipvs/ip_vs_xmit.c |  9 ++++--
 net/sctp/protocol.c             | 14 ++++----
 22 files changed, 230 insertions(+), 147 deletions(-)

-- 
2.5.5
