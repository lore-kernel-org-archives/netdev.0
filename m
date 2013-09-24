From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 0/2] l2tp: add vlan pseudowire support
Date: Tue, 24 Sep 2013 17:27:08 +0100
Message-ID: <1380040030-6648-1-git-send-email-jchapman@katalix.com>
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:42169 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752856Ab3IXQ1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 12:27:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This RFC patch series adds L2TP vlan pseudowire support by creating a
vlan netdev in addition to the l2tpeth netdev when the user creates
vlan pseudowires. To do so, new symbols are exported in 8021q to allow
l2tp to create and destroy vlan netdevs. The existing L2TP netlink API
already contains attributes for vlan pseudowires but they have been
unused to date.

L2TP vlan pseudowires are similar to the existing L2TP ethernet
pseudowires except that vlan pseudowires always carry only one vlan
and never carry untagged frames, while ethernet pseudowires can carry
any ethernet frame (tagged or untagged). It is possible to create vlan
interfaces on top of l2tpeth interfaces (ethernet pseudowires) today
using standard tools. But for VLAN pseudowires, there must be one and
only one vlan.

The changes in this patch series create a pair of netdevs per vlan
pseudowire: a vlan netdev and an l2tpeth netdev; the l2tpeth netdev is
used as the master for the vlan netdev. The master netdev must not be
configured since untagged frames are not allowed in vlan pseudowires.

Some L2TP setups have thousands of L2TP pseudowires so creating two
netdevs per vlan pseudowire isn't ideal when one might suffice. Should I
investigate changing 8021q to allow for the case where there is no
master netdev?


James Chapman (2):
  vlan: export functions to register/unregister vlan devices
  l2tp: add vlan pseudowire support

 include/linux/if_vlan.h |   11 ++++++
 net/8021q/vlan.c        |   82 ++++++++++++++++++++++++++++------------------
 net/l2tp/l2tp_eth.c     |   73 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 132 insertions(+), 34 deletions(-)
