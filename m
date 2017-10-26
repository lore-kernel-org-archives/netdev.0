From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 0/3] net: Allow non-fatal messages to be passed in extack
Date: Wed, 25 Oct 2017 22:08:02 -0700
Message-ID: <1508994485-24533-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, johannes.berg@intel.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:43136 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdJZFIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 01:08:13 -0400
Received: by mail-pf0-f195.google.com with SMTP id a8so1678852pfc.0
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 22:08:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many cases where networking subsystems throw non-fatal warning
messages that end up in dmesg / kernel log to which a user making the
change is completely oblivious. This set makes the extack facility
usable for returning such messages. The case in point here is spectrum
and adding FIB rules which causes an offload abort. Make the use case
more user friendly by letting the user know that offload is no longer
happening.

David Ahern (3):
  netlink: Allow ext_ack to carry non-error messages
  net: Add extack to fib_notifier_info
  mlxsw: spectrum_router: Return extack message on abort due to fib
    rules

 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 97 ++++++++++++----------
 include/net/fib_notifier.h                         |  1 +
 net/core/fib_rules.c                               |  9 +-
 net/ipv4/fib_trie.c                                | 13 +--
 net/ipv6/ip6_fib.c                                 | 15 ++--
 net/netlink/af_netlink.c                           | 18 ++--
 6 files changed, 85 insertions(+), 68 deletions(-)

-- 
2.1.4
