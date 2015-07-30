From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net-next 0/9] OVS conntrack support
Date: Thu, 30 Jul 2015 11:12:34 -0700
Message-ID: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The goal of this series is to allow OVS to send packets through the Linux
kernel connection tracker, and subsequently match on fields populated by
conntrack.

This version includes new handling of IPv4 and IPv6 fragments, support for
conntrack labels, and tracking connections via helpers. The kernel module tests
distributed with the corresponding OVS userspace check a variety of scenarios
implementing one-way firewalls, two-way firewalls, with and without IP
fragments, VLANs and VXLAN tunnels, and in conjunction with FTP helpers, for
both IPv4 and IPv6 traffic.

This functionality is enabled through the CONFIG_OPENVSWITCH_CONNTRACK option.

The branch below has been updated with the corresponding userspace pieces:
https://github.com/justinpettit/ovs conntrack

Joe Stringer (8):
  openvswitch: Scrub packet in ovs_vport_receive()
  openvswitch: Serialize acts with original netlink len
  openvswitch: Move MASKED* macros to datapath.h
  ipv6: Export nf_ct_frag6_gather()
  openvswitch: Add conntrack action
  netfilter: Always export nf_connlabels_replace()
  openvswitch: Allow matching on conntrack label
  openvswitch: Allow attaching helpers to ct action

Justin Pettit (1):
  openvswitch: Allow matching on conntrack mark

 include/uapi/linux/openvswitch.h        |  49 +++
 net/ipv6/netfilter/nf_conntrack_reasm.c |   1 +
 net/netfilter/nf_conntrack_labels.c     |   2 -
 net/openvswitch/Kconfig                 |  12 +
 net/openvswitch/Makefile                |   1 +
 net/openvswitch/actions.c               | 224 ++++++++--
 net/openvswitch/conntrack.c             | 758 ++++++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h             | 128 ++++++
 net/openvswitch/datapath.c              |  70 ++-
 net/openvswitch/datapath.h              |  12 +
 net/openvswitch/flow.c                  |   5 +
 net/openvswitch/flow.h                  |   9 +
 net/openvswitch/flow_netlink.c          | 103 ++++-
 net/openvswitch/flow_netlink.h          |   4 +-
 net/openvswitch/vport.c                 |   4 +
 15 files changed, 1317 insertions(+), 65 deletions(-)
 create mode 100644 net/openvswitch/conntrack.c
 create mode 100644 net/openvswitch/conntrack.h

-- 
2.1.4
