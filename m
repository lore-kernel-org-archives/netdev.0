From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv6 net-next 00/10] OVS conntrack support
Date: Wed, 26 Aug 2015 11:31:43 -0700
Message-ID: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com,
	netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The goal of this series is to allow OVS to send packets through the Linux
kernel connection tracker, and subsequently match on fields populated by
conntrack. This functionality is enabled through a new
CONFIG_OPENVSWITCH_CONNTRACK option.

This version addresses the feedback from v5, primarily checking the behaviour
is correct with different configurations such as disabling
CONFIG_OPENVSWITCH_CONNTRACK or disabling individual conntrack features like
connlabels.

The branch below has been updated with the corresponding userspace pieces:
https://github.com/joestringer/ovs dev/ct_20150818

Joe Stringer (10):
  openvswitch: Serialize acts with original netlink len
  openvswitch: Move MASKED* macros to datapath.h
  ipv6: Export nf_ct_frag6_gather()
  dst: Add __skb_dst_copy() variation
  openvswitch: Add conntrack action
  openvswitch: Allow matching on conntrack mark
  netfilter: Always export nf_connlabels_replace()
  netfilter: connlabels: Export setting connlabel length
  openvswitch: Allow matching on conntrack label
  openvswitch: Allow attaching helpers to ct action

 include/net/dst.h                           |   9 +-
 include/net/netfilter/nf_conntrack_labels.h |   4 +
 include/uapi/linux/openvswitch.h            |  58 +++
 net/ipv6/netfilter/nf_conntrack_reasm.c     |   1 +
 net/netfilter/nf_conntrack_labels.c         |  34 +-
 net/netfilter/xt_connlabel.c                |  16 +-
 net/openvswitch/Kconfig                     |  11 +
 net/openvswitch/Makefile                    |   2 +
 net/openvswitch/actions.c                   | 229 +++++++--
 net/openvswitch/conntrack.c                 | 744 ++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h                 |  86 ++++
 net/openvswitch/datapath.c                  |  86 +++-
 net/openvswitch/datapath.h                  |  13 +
 net/openvswitch/flow.c                      |   6 +-
 net/openvswitch/flow.h                      |  11 +-
 net/openvswitch/flow_netlink.c              | 119 ++++-
 net/openvswitch/flow_netlink.h              |  13 +-
 net/openvswitch/vport.c                     |   1 +
 18 files changed, 1336 insertions(+), 107 deletions(-)
 create mode 100644 net/openvswitch/conntrack.c
 create mode 100644 net/openvswitch/conntrack.h

-- 
2.1.4
