From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 0/6] net: another round of extack handling for routing
Date: Wed, 24 May 2017 21:54:36 -0600
Message-ID: <20170525035442.51407-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34974 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941523AbdEYDyr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 23:54:47 -0400
Received: by mail-pf0-f194.google.com with SMTP id u26so36373084pfd.2
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 20:54:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set focuses on passing extack through lwtunnel and MPLS with
additional catches for IPv4 route add and minor cleanups in MPLS
encountered passing the extack arg around.

David Ahern (6):
  net: ipv4: Add extack message for invalid prefix or length
  net: lwtunnel: Add extack to encap attr validation
  net: plumb extack arg down to lwtunnel build state
  net: Fill in extack for mpls lwt encap
  net: mpls: Add extack messages for route add and delete failures
  net: mpls: minor cleanups

 include/linux/netlink.h   |  10 +++
 include/net/ip_fib.h      |   3 +-
 include/net/lwtunnel.h    |  22 ++++--
 net/core/lwt_bpf.c        |   5 +-
 net/core/lwtunnel.c       |  38 ++++++++--
 net/ipv4/fib_frontend.c   |  12 +--
 net/ipv4/fib_lookup.h     |   3 +-
 net/ipv4/fib_semantics.c  |  20 ++---
 net/ipv4/fib_trie.c       |  22 ++++--
 net/ipv4/ip_tunnel_core.c |  11 ++-
 net/ipv6/ila/ila_lwt.c    |   5 +-
 net/ipv6/route.c          |   6 +-
 net/ipv6/seg6_iptunnel.c  |   5 +-
 net/mpls/af_mpls.c        | 184 ++++++++++++++++++++++++++++++++++------------
 net/mpls/internal.h       |   4 +-
 net/mpls/mpls_iptunnel.c  |  17 +++--
 16 files changed, 259 insertions(+), 108 deletions(-)

-- 
2.11.0 (Apple Git-81)
