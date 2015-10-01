From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 0/4] openvswitch: add IPv6 tunneling support
Date: Thu,  1 Oct 2015 16:44:38 +0200
Message-ID: <cover.1443710454.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750923AbbJAOpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 10:45:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This builds on the previous work that added IPv6 support to lwtunnels and
adds IPv6 tunneling support to ovs.

To use IPv6 tunneling, there needs to be a metadata based tunnel net_device
created and added to the ovs bridge. Currently, only vxlan is supported by
the kernel, with geneve to follow shortly. There's no need nor intent to add
a support for this into the vport-vxlan (etc.) compat layer.

Jiri Benc (4):
  openvswitch: add tunnel protocol to sw_flow_key
  openvswitch: netlink attributes for IPv6 tunneling
  ip_tunnels: introduce ip6_tunnel_key_init
  openvswitch: IPv6 support for ovs_tunnel_get_egress_info

 include/net/dst_metadata.h       |  18 ++----
 include/net/ip_tunnels.h         |  40 +++++++++---
 include/uapi/linux/openvswitch.h |   2 +
 net/openvswitch/flow.c           |   4 +-
 net/openvswitch/flow.h           |   1 +
 net/openvswitch/flow_netlink.c   | 129 +++++++++++++++++++++++++++------------
 net/openvswitch/flow_table.c     |   2 +-
 net/openvswitch/vport-geneve.c   |   4 +-
 net/openvswitch/vport-gre.c      |   4 +-
 net/openvswitch/vport-vxlan.c    |   6 +-
 net/openvswitch/vport.c          |  62 +++++++++++++------
 net/openvswitch/vport.h          |  26 ++++++++
 12 files changed, 211 insertions(+), 87 deletions(-)

-- 
1.8.3.1
