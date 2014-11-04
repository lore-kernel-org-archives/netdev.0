From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next] Open vSwitch
Date: Mon,  3 Nov 2014 22:00:46 -0800
Message-ID: <1415080846-1623-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog014.obsmtp.com ([74.125.150.68]:38413 "HELO
	na6sys009bog014.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751122AbaKEUA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:00:59 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so1437412pab.32
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:00:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First two patches are related to OVS MPLS support. Rest of patches
are various refactoring and minor improvements to openvswitch.

----------------------------------------------------------------

The following changes since commit 30349bdbc4da5ecf0efa25556e3caff9c9b8c5f7:

  net: phy: spi_ks8995: remove sysfs bin file by registered attribute (2014-11-04 17:18:45 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to fb90c8d8d5169d4dfbe5896721367e1904638a91:

  openvswitch: Avoid NULL mask check while building mask (2014-11-04 22:20:33 -0800)

----------------------------------------------------------------
Andy Zhou (2):
      openvswitch: refactor do_output() to move NULL check out of fast path
      openvswitch: Refactor get_dp() function into multiple access APIs.

Chunhe Li (1):
      openvswitch: Drop packets when interdev is not up

Jarno Rajahalme (1):
      openvswitch: Fix the type of struct ovs_key_nd nd_target field.

Jesse Gross (1):
      openvswitch: Additional logging for -EINVAL on flow setups.

Joe Stringer (3):
      openvswitch: Remove redundant tcp_flags code.
      openvswitch: Refactor ovs_flow_cmd_fill_info().
      openvswitch: Move key_attr_size() to flow_netlink.h.

Lorand Jakab (1):
      openvswitch: Remove flow member from struct ovs_skb_cb

Pravin B Shelar (4):
      net: Remove MPLS GSO feature.
      openvswitch: Move table destroy to dp-rcu callback.
      openvswitch: Refactor action alloc and copy api.
      openvswitch: Avoid NULL mask check while building mask

Simon Horman (1):
      openvswitch: Add basic MPLS support to kernel

 include/linux/netdev_features.h      |   7 +-
 include/linux/netdevice.h            |   1 -
 include/linux/skbuff.h               |   3 -
 include/net/mpls.h                   |  39 +++++
 include/uapi/linux/openvswitch.h     |  38 ++++-
 net/core/dev.c                       |   3 +-
 net/core/ethtool.c                   |   1 -
 net/ipv4/af_inet.c                   |   1 -
 net/ipv4/tcp_offload.c               |   1 -
 net/ipv4/udp_offload.c               |   3 +-
 net/ipv6/ip6_offload.c               |   1 -
 net/ipv6/udp_offload.c               |   3 +-
 net/mpls/mpls_gso.c                  |   3 +-
 net/openvswitch/Kconfig              |   1 +
 net/openvswitch/actions.c            | 136 ++++++++++++---
 net/openvswitch/datapath.c           | 215 ++++++++++++-----------
 net/openvswitch/datapath.h           |   4 +-
 net/openvswitch/flow.c               |  30 ++++
 net/openvswitch/flow.h               |  17 +-
 net/openvswitch/flow_netlink.c       | 322 +++++++++++++++++++++++++----------
 net/openvswitch/flow_netlink.h       |   5 +-
 net/openvswitch/flow_table.c         |  11 +-
 net/openvswitch/flow_table.h         |   2 +-
 net/openvswitch/vport-internal_dev.c |   5 +
 24 files changed, 606 insertions(+), 246 deletions(-)
 create mode 100644 include/net/mpls.h
