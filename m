From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 0/3] net: Allow non-fatal messages to be passed in extack
Date: Fri, 27 Oct 2017 17:37:11 -0700
Message-ID: <1509151034-28278-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, johannes.berg@intel.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:45001 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdJ1AhW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:37:22 -0400
Received: by mail-pf0-f195.google.com with SMTP id x7so6049417pfa.1
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:37:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many cases where networking subsystems throw non-fatal warning
messages that end up in dmesg / kernel log to which a user making the
change is completely oblivious. This set makes the extack facility
usable for returning such messages.

The case in point here is spectrum and adding FIB rules which causes an
offload abort. Make the use case more user friendly by letting the user
know that offload is no longer happening because of the rule change.

v2
- kept the offload abort in a work queue entry per Ido's comment

David Ahern (3):
  netlink: Allow ext_ack to carry non-error messages
  net: Add extack to fib_notifier_info
  mlxsw: spectrum_router: Return extack message on abort due to fib
    rules

 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 108 +++++++++++++--------
 include/net/fib_notifier.h                         |   1 +
 net/core/fib_rules.c                               |   9 +-
 net/ipv4/fib_trie.c                                |  13 ++-
 net/ipv6/ip6_fib.c                                 |  15 +--
 net/netlink/af_netlink.c                           |  18 ++--
 6 files changed, 99 insertions(+), 65 deletions(-)

-- 
2.1.4
