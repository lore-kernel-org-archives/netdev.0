From: Patrick McHardy <kaber@trash.net>
Subject: [NET 00/05]: netdevice rx mode synchronization fixes + macvlan driver
Date: Thu, 12 Jul 2007 20:13:39 +0200 (MEST)
Message-ID: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54173 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781AbXGLSNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 14:13:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches introduce a new net_device hook for synchronizing promiscous
and allmulti state to an underlying device (as done by 8021q, bonding,
maxvlan, ..) to fix some races that occur when doing this from
dev->set_multicast_list. They also introduce two helpers for multicast
list synchonization and change VLAN to make use of all of this (mainly to
show that its not only for macvlan, but it also fixes some real races).
The last patch adds the macvlan driver.

Please apply, thanks.


 MAINTAINERS                |    6 +
 drivers/net/Kconfig        |   10 +
 drivers/net/Makefile       |    1 +
 drivers/net/macvlan.c      |  496 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_macvlan.h |    9 +
 include/linux/if_vlan.h    |    7 -
 include/linux/netdevice.h  |    8 +
 net/8021q/vlan.c           |    1 +
 net/8021q/vlan.h           |    1 +
 net/8021q/vlan_dev.c       |  167 ++-------------
 net/core/dev.c             |   43 ++++-
 net/core/dev_mcast.c       |   75 +++++++
 12 files changed, 670 insertions(+), 154 deletions(-)
 create mode 100644 drivers/net/macvlan.c
 create mode 100644 include/linux/if_macvlan.h

Patrick McHardy (5):
      [NET]: Add net_device change_rx_mode callback
      [NET]: dev_mcast: add multicast list synchronization helpers
      [VLAN]: Fix promiscous/allmulti synchronization races
      [VLAN]: Use multicast list synchronization helpers
      [NET]: Add macvlan driver
