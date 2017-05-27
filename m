From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 0/9] net: another round of extack handling for routing
Date: Sat, 27 May 2017 16:19:24 -0600
Message-ID: <20170527221933.57644-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35498 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750746AbdE0WTj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 18:19:39 -0400
Received: by mail-pg0-f65.google.com with SMTP id i63so2469695pgd.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 15:19:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set focuses on passing extack through lwtunnel and MPLS with
additional catches for IPv4 route add and minor cleanups in MPLS
encountered passing the extack arg around.

v2
- mindful of bloat adding duplicate messages
  + refactored prefix and prefix length checks in ipv4's fib_table_insert
    and fib_table_del
  + refactored label check in mpls

- split mpls cleanups into 2 patches
  + move nla_get_via up in af_mpls to avoid forward declaration

David Ahern (9):
  net: ipv4: refactor key and length checks
  net: ipv4: Add extack message for invalid prefix or length
  net: lwtunnel: Add extack to encap attr validation
  net: add extack arg to lwtunnel build state
  net: Fill in extack for mpls lwt encap
  net: mpls: Pull common label check into helper
  net: mpls: Add extack messages for route add and delete failures
  net: mpls: Make nla_get_via in af_mpls.c
  net: mpls: remove unnecessary initialization of err

 include/linux/netlink.h   |  10 ++
 include/net/ip_fib.h      |   3 +-
 include/net/lwtunnel.h    |  22 ++--
 net/core/lwt_bpf.c        |   5 +-
 net/core/lwtunnel.c       |  38 +++++--
 net/ipv4/fib_frontend.c   |  13 ++-
 net/ipv4/fib_lookup.h     |   3 +-
 net/ipv4/fib_semantics.c  |  20 ++--
 net/ipv4/fib_trie.c       |  34 +++---
 net/ipv4/ip_tunnel_core.c |  11 +-
 net/ipv6/ila/ila_lwt.c    |   5 +-
 net/ipv6/route.c          |   6 +-
 net/ipv6/seg6_iptunnel.c  |   5 +-
 net/mpls/af_mpls.c        | 266 +++++++++++++++++++++++++++++-----------------
 net/mpls/internal.h       |   4 +-
 net/mpls/mpls_iptunnel.c  |  17 +--
 16 files changed, 301 insertions(+), 161 deletions(-)

-- 
2.11.0 (Apple Git-81)
