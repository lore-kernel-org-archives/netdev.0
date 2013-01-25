From: pablo@netfilter.org
Subject: [PATCH 00/21] netfilter updates for net-next
Date: Fri, 25 Jan 2013 14:54:32 +0100
Message-ID: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

This batch contains netfilter updates for you net-next tree, they are:

* The new connlabel extension for x_tables, that allows us to attach
  labels to each conntrack flow. The kernel implementation uses a
  bitmask and there's a file in user-space that maps the bits with the
  corresponding string for each existing label. By now, you can attach
  up to 128 overlapping labels. From Florian Westphal.

* A new round of improvements for the netns support for conntrack.
  Gao feng has moved many of the initialization code of each module
  of the netns init path. He also made several code refactoring, that
  code looks cleaner to me now.

* Added documentation for all possible tweaks for nf_conntrack via
  sysctl, from Jiri Pirko.

* Cisco 7941/7945 IP phone support for our SIP conntrack helper,
  from Kevin Cernekee.

* Missing header file in the snmp helper, from Stephen Hemminger.

* Finally, a couple of fixes to resolve minor issues with these
  changes, from myself.

You can pull these changes from:

git://1984.lsi.us.es/nf-next master

Thanks!

Florian Westphal (3):
  netfilter: add connlabel conntrack extension
  netfilter: ctnetlink: deliver labels to userspace
  netfilter: ctnetlink: allow userspace to modify labels

Gao feng (11):
  netfilter: nf_conntrack: move initialization out of pernet operations
  netfilter: nf_ct_expect: move initialization out of pernet_operations
  netfilter: nf_ct_acct: move initialization out of pernet_operations
  netfilter: nf_ct_tstamp: move initialization out of pernet_operations
  netfilter: nf_ct_ecache: move initialization out of pernet_operations
  netfilter: nf_ct_timeout: move initialization out of pernet_operations
  netfilter: nf_ct_helper: move initialization out of pernet_operations
  netfilter: nf_ct_labels: move initialization out of pernet_operations
  netfilter: nf_ct_proto: move initialization out of pernet_operations
  netfilter: nf_conntrack: refactor l3proto support for netns
  netfilter: nf_conntrack: refactor l4proto support for netns

Jiri Pirko (1):
  netfilter: doc: add nf_conntrack sysctl api documentation

Kevin Cernekee (1):
  netfilter: nf_ct_sip: support Cisco 7941/7945 IP phones

Pablo Neira Ayuso (3):
  netfilter: add missing xt_bpf.h header in installation
  netfilter: add missing xt_connlabel.h header in installation
  netfilter: nf_conntrack: fix compilation if sysctl are disabled

Willem de Bruijn (1):
  netfilter: x_tables: add xt_bpf match

stephen hemminger (1):
  netfilter: nf_ct_snmp: add include file

 Documentation/networking/nf_conntrack-sysctl.txt   |  176 ++++++++++++++++++
 include/linux/netfilter/nf_conntrack_sip.h         |    3 +
 include/net/netfilter/nf_conntrack_acct.h          |    6 +-
 include/net/netfilter/nf_conntrack_core.h          |   15 +-
 include/net/netfilter/nf_conntrack_ecache.h        |   19 +-
 include/net/netfilter/nf_conntrack_expect.h        |    7 +-
 include/net/netfilter/nf_conntrack_extend.h        |    4 +
 include/net/netfilter/nf_conntrack_helper.h        |    7 +-
 include/net/netfilter/nf_conntrack_l3proto.h       |   11 +-
 include/net/netfilter/nf_conntrack_l4proto.h       |   10 +-
 include/net/netfilter/nf_conntrack_labels.h        |   58 ++++++
 include/net/netfilter/nf_conntrack_timeout.h       |    8 +-
 include/net/netfilter/nf_conntrack_timestamp.h     |   21 ++-
 include/net/netns/conntrack.h                      |    4 +
 include/uapi/linux/netfilter/Kbuild                |    2 +
 include/uapi/linux/netfilter/nf_conntrack_common.h |    1 +
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |    2 +
 include/uapi/linux/netfilter/xt_bpf.h              |   17 ++
 include/uapi/linux/netfilter/xt_connlabel.h        |   12 ++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |   82 ++++++---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |   86 ++++++---
 net/netfilter/Kconfig                              |   27 +++
 net/netfilter/Makefile                             |    3 +
 net/netfilter/nf_conntrack_acct.c                  |   36 ++--
 net/netfilter/nf_conntrack_core.c                  |  191 ++++++++++++--------
 net/netfilter/nf_conntrack_ecache.c                |   37 ++--
 net/netfilter/nf_conntrack_expect.c                |   53 +++---
 net/netfilter/nf_conntrack_helper.c                |   53 +++---
 net/netfilter/nf_conntrack_labels.c                |  112 ++++++++++++
 net/netfilter/nf_conntrack_netlink.c               |   88 +++++++++
 net/netfilter/nf_conntrack_proto.c                 |   92 ++++------
 net/netfilter/nf_conntrack_proto_dccp.c            |   43 +++--
 net/netfilter/nf_conntrack_proto_gre.c             |   23 ++-
 net/netfilter/nf_conntrack_proto_sctp.c            |   43 +++--
 net/netfilter/nf_conntrack_proto_udplite.c         |   40 +++-
 net/netfilter/nf_conntrack_sip.c                   |   17 ++
 net/netfilter/nf_conntrack_snmp.c                  |    1 +
 net/netfilter/nf_conntrack_standalone.c            |   63 ++++---
 net/netfilter/nf_conntrack_timeout.c               |   23 +--
 net/netfilter/nf_conntrack_timestamp.c             |   39 ++--
 net/netfilter/nf_nat_sip.c                         |   27 ++-
 net/netfilter/xt_bpf.c                             |   73 ++++++++
 net/netfilter/xt_connlabel.c                       |   99 ++++++++++
 43 files changed, 1305 insertions(+), 429 deletions(-)
 create mode 100644 Documentation/networking/nf_conntrack-sysctl.txt
 create mode 100644 include/net/netfilter/nf_conntrack_labels.h
 create mode 100644 include/uapi/linux/netfilter/xt_bpf.h
 create mode 100644 include/uapi/linux/netfilter/xt_connlabel.h
 create mode 100644 net/netfilter/nf_conntrack_labels.c
 create mode 100644 net/netfilter/xt_bpf.c
 create mode 100644 net/netfilter/xt_connlabel.c

-- 
1.7.10.4

