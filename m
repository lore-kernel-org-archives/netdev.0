From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCHv2 next 0/3] ipvlan introduce l3s mode
Date: Mon, 12 Sep 2016 11:01:35 -0700
Message-ID: <1473703295-26540-1-git-send-email-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34454 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754058AbcILSBo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 14:01:44 -0400
Received: by mail-pf0-f194.google.com with SMTP id g202so8423170pfb.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 11:01:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Same old problem with new approach especially from suggestions from
earlier patch-series.

First thing is that this is introduced as a new mode rather than
modifying the old (L3) mode. So the behavior of the existing modes is
preserved as it is and the new L3s mode obeys iptables so that intended
conn-tracking can work. 

To do this, the code uses newly added l3mdev_rcv() handler and an
Iptables hook. l3mdev_rcv() to perform an inbound route lookup with the
correct (IPvlan slave) interface and then IPtable-hook at LOCAL_INPUT
to change the input device from master to the slave to complete the
formality.

Supporting stack changes are trivial changes to export symbol to get
IPv4 equivalent code exported for IPv6 and to allow netfilter hook
registration code to allow caller to hold RTNL. Please look into
individual patches for details.

Mahesh Bandewar (3):
  ipv6: Export p6_route_input_lookup symbol
  net: Add _nf_(un)register_hooks symbols
  ipvlan: Introduce l3s mode

 Documentation/networking/ipvlan.txt |  7 ++-
 drivers/net/Kconfig                 |  1 +
 drivers/net/ipvlan/ipvlan.h         |  7 +++
 drivers/net/ipvlan/ipvlan_core.c    | 94 +++++++++++++++++++++++++++++++++++++
 drivers/net/ipvlan/ipvlan_main.c    | 60 ++++++++++++++++++++---
 include/linux/netfilter.h           |  2 +
 include/net/ip6_route.h             |  3 ++
 include/uapi/linux/if_link.h        |  1 +
 net/ipv6/route.c                    |  7 +--
 net/netfilter/core.c                | 51 ++++++++++++++++++--
 10 files changed, 217 insertions(+), 16 deletions(-)


v1: Initial post
v2: Text correction and config changed from "select" to "depends on"
-- 
2.8.0.rc3.226.g39d4020
