From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v6 0/3] bridge: neigh msg proxy and flood suppression support
Date: Fri,  6 Oct 2017 22:12:36 -0700
Message-ID: <1507353159-46814-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        stephen@networkplumber.org, makita.toshiaki@lab.ntt.co.jp,
        bridge@lists.linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:55549 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750758AbdJGFMo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 01:12:44 -0400
Received: by mail-pf0-f180.google.com with SMTP id 17so2127776pfn.12
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 22:12:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series implements arp and nd suppression in the bridge
driver for ethernet vpns. It implements rfc7432, section 10
https://tools.ietf.org/html/rfc7432#section-10
for ethernet VPN deployments. It is similar to the existing
BR_PROXYARP* flags but has a few semantic differences to conform
to EVPN standard. Unlike the existing flags, this new flag suppresses
flood of all neigh discovery packets (arp and nd) to tunnel ports.
Supports both vlan filtering and non-vlan filtering bridges.

In case of EVPN, it is mainly used to avoid flooding
of arp and nd packets to tunnel ports like vxlan.

v2 : rebase to latest + address some optimization feedback from Nikolay.
v3 : fix kbuild reported build errors with CONFIG_INET off
v4 : simplify port flag mask as suggested by stephen
v5 : address some feedback from Toshiaki
v6 : some v5 cleanups in nd suppress (keep it consistent with arp suppress)

Roopa Prabhu (3):
  bridge: add new BR_NEIGH_SUPPRESS port flag to suppress arp and nd
    flood
  neigh arp suppress first
  bridge: suppress nd messages from going to BR_NEIGH_SUPPRESS ports

 include/linux/if_bridge.h    |   1 +
 include/uapi/linux/if_link.h |   1 +
 net/bridge/Makefile          |   2 +-
 net/bridge/br_arp_nd_proxy.c | 492 +++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_device.c       |  18 ++
 net/bridge/br_forward.c      |   3 +-
 net/bridge/br_if.c           |   5 +
 net/bridge/br_input.c        |  73 ++-----
 net/bridge/br_netlink.c      |  16 +-
 net/bridge/br_private.h      |   9 +
 net/bridge/br_sysfs_if.c     |   2 +
 11 files changed, 561 insertions(+), 61 deletions(-)
 create mode 100644 net/bridge/br_arp_nd_proxy.c

-- 
2.1.4
