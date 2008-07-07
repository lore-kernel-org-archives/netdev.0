From: Patrick McHardy <kaber@trash.net>
Subject: vlan 00/07: VLAN update part 1
Date: Mon,  7 Jul 2008 14:35:58 +0200 (MEST)
Message-ID: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59262 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbYGGMgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:36:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following is a first VLAN update for net-next-2.6, containing a fix for the
skb->network_header issue pointed out by Lennert, VLAN ethtool support for
querying offload settings, uninlining of __vlan_hwaccel_rx and some assorted
cleanups.

A second update in my queue on top of this one will attack the packet socket
inconsistencies with VLAN acceleration, but I've split the set for easier
review of the more interesting changes.

Please apply, thanks.


 drivers/net/cxgb3/l2t.c         |    2 +-
 drivers/s390/net/qeth_l3_main.c |    4 +-
 include/linux/if_vlan.h         |  204 +++++++++++++--------------------------
 net/8021q/Makefile              |    9 +-
 net/8021q/vlan.c                |   41 ++++-----
 net/8021q/vlan.h                |   67 ++++++++++++-
 net/8021q/vlan_core.c           |   60 ++++++++++++
 net/8021q/vlan_dev.c            |   73 ++++++++------
 net/8021q/vlan_gvrp.c           |    8 +-
 net/8021q/vlanproc.c            |    2 +-
 net/Makefile                    |    4 +-
 11 files changed, 265 insertions(+), 209 deletions(-)
 create mode 100644 net/8021q/vlan_core.c

Joonwoo Park (1):
      vlan: Use is_vlan_dev()

Patrick McHardy (6):
      vlan: fix network_header/mac_header adjustments
      vlan: Add ethtool support
      vlan: uninline __vlan_hwaccel_rx
      vlan: move struct vlan_dev_info to private header
      vlan: remove useless struct hlist_node declaration from if_vlan.h
      vlan: TCI related type and naming cleanups
