From: Jesse Gross <jesse@nicira.com>
Subject: [RFC PATCH 0/7] Move vlan acceleration into networking core.
Date: Wed, 13 Oct 2010 13:02:50 -0700
Message-ID: <1287000177-7126-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:54716 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202Ab0JMUDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 16:03:05 -0400
Received: by pzk33 with SMTP id 33so49024pzk.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 13:03:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware vlan acceleration behaves fairly differently from other types of
offloading, which limits its usefulness.  This patch series aims to bring
it more in line with other common forms of acceleration, such as checksum
offloading and TSO.  In doing this it eliminates common driver bugs, increases
flexibility, and improves performance, while reducing the number of lines of
code.

The first four patches can be applied immediately, while the last three need
to wait until all drivers that support vlan acceleration are updated.  If
people agree that this patch set makes sense I will go ahead and switch over
the dozen or so drivers that would need to change.

Jesse Gross (7):
  ebtables: Allow filtering of hardware accelerated vlan frames.
  vlan: Centralize handling of hardware acceleration.
  bnx2: Update bnx2 to use new vlan accleration.
  ixgbe: Update ixgbe to use new vlan accleration.
  lro: Remove explicit vlan support.
  bonding: Update bonding for new vlan model.
  vlan: Remove accleration legacy functions.

 drivers/net/bnx2.c              |   75 ++--------------------
 drivers/net/bnx2.h              |    4 -
 drivers/net/bonding/bond_alb.c  |    8 +--
 drivers/net/bonding/bond_ipv6.c |    5 +-
 drivers/net/bonding/bond_main.c |  134 ++++++++-------------------------------
 drivers/net/bonding/bonding.h   |    1 -
 drivers/net/ixgbe/ixgbe.h       |    4 +-
 drivers/net/ixgbe/ixgbe_main.c  |   60 +++++-------------
 include/linux/if_vlan.h         |   87 ++++++++------------------
 include/linux/inet_lro.h        |   20 ------
 include/linux/netdevice.h       |   20 +++---
 net/8021q/vlan.c                |  100 +++++++-----------------------
 net/8021q/vlan.h                |   17 -----
 net/8021q/vlan_core.c           |  132 ++++++--------------------------------
 net/8021q/vlan_dev.c            |    2 +-
 net/bridge/br_netfilter.c       |   16 +++--
 net/bridge/netfilter/ebt_vlan.c |   42 +++++++-----
 net/bridge/netfilter/ebtables.c |   15 +++-
 net/core/dev.c                  |   42 +++++++++++--
 net/ipv4/inet_lro.c             |   74 +++------------------
 20 files changed, 225 insertions(+), 633 deletions(-)

