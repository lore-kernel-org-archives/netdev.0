From: Jesse Gross <jesse@nicira.com>
Subject: [GIT net-next] Open vSwitch
Date: Tue, 27 Aug 2013 13:20:37 -0700
Message-ID: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:46869 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752076Ab3H0UU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:20:56 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so5305774pbc.15
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:20:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of significant new features and optimizations for net-next/3.12.
Highlights are:
 * "Megaflows", an optimization that allows userspace to specify which
   flow fields were used to compute the results of the flow lookup.
   This allows for a major reduction in flow setups (the major
   performance bottleneck in Open vSwitch) without reducing flexibility.
 * Converting netlink dump operations to use RCU, allowing for
   additional parallelism in userspace.
 * Matching and modifying SCTP protocol fields.

The following changes since commit 2771399ac9986c75437a83b1c723493cfcdfa439:

  fs_enet: cleanup clock API use (2013-08-22 22:13:54 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git master

for you to fetch changes up to 5828cd9a68873df1340b420371c02c47647878fb:

  openvswitch: optimize flow compare and mask functions (2013-08-27 13:13:09 -0700)

----------------------------------------------------------------
Andy Zhou (3):
      openvswitch: Mega flow implementation
      openvswitch: Rename key_len to key_end
      openvswitch: optimize flow compare and mask functions

Cong Wang (1):
      openvswitch: check CONFIG_OPENVSWITCH_GRE in makefile

Jiri Pirko (1):
      openvswitch:: link upper device for port devices

Joe Stringer (2):
      net: Add NEXTHDR_SCTP to ipv6.h
      openvswitch: Add SCTP support

Justin Pettit (1):
      openvswitch: Fix argument descriptions in vport.c.

Pravin B Shelar (3):
      openvswitch: Use RCU lock for flow dump operation.
      openvswitch: Use RCU lock for dp dump operation.
      openvswitch: Use non rcu hlist_del() flow table entry.

 Documentation/networking/openvswitch.txt |   40 +
 include/net/ipv6.h                       |    1 +
 include/uapi/linux/openvswitch.h         |   15 +-
 net/openvswitch/Kconfig                  |    1 +
 net/openvswitch/Makefile                 |    5 +-
 net/openvswitch/actions.c                |   45 +-
 net/openvswitch/datapath.c               |  176 ++--
 net/openvswitch/datapath.h               |    6 +
 net/openvswitch/flow.c                   | 1485 +++++++++++++++++++++---------
 net/openvswitch/flow.h                   |   89 +-
 net/openvswitch/vport-gre.c              |    3 -
 net/openvswitch/vport-netdev.c           |   20 +-
 net/openvswitch/vport.c                  |    3 +-
 13 files changed, 1346 insertions(+), 543 deletions(-)
