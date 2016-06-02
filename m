From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v10 0/5] openvswitch: support for layer 3 encapsulated packets
Date: Thu,  2 Jun 2016 15:24:41 +0900
Message-ID: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
Cc: dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33538 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbcFBGYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 02:24:55 -0400
Received: by mail-pf0-f182.google.com with SMTP id b124so27510252pfb.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 23:24:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the core of this patch set is removing the assumption in Open vSwitch
datapath that all packets have Ethernet header. Support for layer 3 GRE
tunnels is also added by this patchset.

The implementation relies on the presence of pop_eth and push_eth actions
in datapath flows to facilitate adding and removing Ethernet headers as
appropriate. The construction of such flows is left up to user-space.

This series is based on work by Lorand Jakab, Thomas Morin and others.
And it relies on recently merged work by Jiri Benc, much thanks to him for
his help.

This patch set is comprised of kernel patches against net-next.

To aid review it and the above dependency is available at:

    tree: https://github.com/horms/openvswitch
    branch: me/l3-vpn
    tag: l3-vpn-v10

There is a companion patch set for the Open vSwitch user-space code
which I will post separately to the dev@openvswitch.org mailing list as:

    "[PATCH v11 0/5] userspace: Support for layer 3 encapsulated packets"


Changes since the previous posting are noted in the changelogs
of individual patches.


Lorand Jakab (1):
  openvswitch: add layer 3 flow/port support

Simon Horman (4):
  net: add skb_vlan_accel helper
  openvswitch: set skb protocol and mac_len when receiving on internal
    device
  openvswitch: add support to push and pop mpls for layer3 packets
  openvswitch: use ipgre tunnel rather than gretap tunnel

 include/linux/skbuff.h               |   1 +
 include/net/gre.h                    |   4 +-
 include/uapi/linux/openvswitch.h     |  13 +++
 net/core/skbuff.c                    |  28 +++--
 net/ipv4/ip_gre.c                    |   9 +-
 net/openvswitch/actions.c            |  72 +++++++++++--
 net/openvswitch/datapath.c           |  13 +--
 net/openvswitch/flow.c               |  57 ++++++----
 net/openvswitch/flow.h               |   4 +-
 net/openvswitch/flow_netlink.c       | 200 +++++++++++++++++++++++++----------
 net/openvswitch/vport-geneve.c       |   2 +-
 net/openvswitch/vport-gre.c          |   4 +-
 net/openvswitch/vport-internal_dev.c |  10 ++
 net/openvswitch/vport-netdev.c       |  43 +++++++-
 net/openvswitch/vport-netdev.h       |   2 +
 net/openvswitch/vport-vxlan.c        |   2 +-
 16 files changed, 344 insertions(+), 120 deletions(-)

-- 
2.1.4
