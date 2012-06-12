From: pablo@netfilter.org
Subject: [PATCH 0/7] [RFCv2] new user-space connection tracking helper infrastructure
Date: Tue, 12 Jun 2012 20:06:13 +0200
Message-ID: <1339524380-2707-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi!

This the second round for the kernel patches that add the newly revamped
user-space cthelper infrastructure as described by:

http://lwn.net/Articles/500196/

This round fixes issues that were spotted by Jan Engelhardt, Joe Perches and
Ferenc Wagner. This also includes some improvements I made myself.

Comments welcome.

Pablo Neira Ayuso (7):
  netfilter: nf_ct_helper: allocate 16 bytes for the helper and policy names
  netfilter: nf_ct_ext: support variable length extensions
  netfilter: nf_ct_helper: implement variable length helper private  data
  netfilter: add glue code to integrate nfnetlink_queue and ctnetlink
  netfilter: nfnetlink_queue: add NAT TCP sequence adjustment if packet mangled
  netfilter: ctnetlink: add CTA_HELP_INFO attribute
  netfilter: add user-space connection tracking helper infrastructure

 include/linux/netfilter.h                      |   12 +
 include/linux/netfilter/Kbuild                 |    1 +
 include/linux/netfilter/nf_conntrack_sip.h     |    2 +
 include/linux/netfilter/nfnetlink.h            |    3 +-
 include/linux/netfilter/nfnetlink_conntrack.h  |    1 +
 include/linux/netfilter/nfnetlink_cthelper.h   |   55 ++
 include/linux/netfilter/nfnetlink_queue.h      |    3 +
 include/linux/netfilter_ipv4.h                 |    1 +
 include/linux/netfilter_ipv6.h                 |    1 +
 include/net/netfilter/nf_conntrack.h           |   35 +-
 include/net/netfilter/nf_conntrack_expect.h    |    4 +-
 include/net/netfilter/nf_conntrack_extend.h    |    7 +-
 include/net/netfilter/nf_conntrack_helper.h    |   29 +-
 include/net/netfilter/nf_nat_helper.h          |    4 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   49 +-
 net/ipv4/netfilter/nf_nat_amanda.c             |    4 +-
 net/ipv4/netfilter/nf_nat_h323.c               |    8 +-
 net/ipv4/netfilter/nf_nat_helper.c             |   13 +
 net/ipv4/netfilter/nf_nat_pptp.c               |    6 +-
 net/ipv4/netfilter/nf_nat_tftp.c               |    4 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   49 +-
 net/netfilter/Kconfig                          |    8 +
 net/netfilter/Makefile                         |    1 +
 net/netfilter/core.c                           |    4 +
 net/netfilter/nf_conntrack_core.c              |    3 +-
 net/netfilter/nf_conntrack_extend.c            |   16 +-
 net/netfilter/nf_conntrack_ftp.c               |   11 +-
 net/netfilter/nf_conntrack_h323_main.c         |   16 +-
 net/netfilter/nf_conntrack_helper.c            |   32 +-
 net/netfilter/nf_conntrack_irc.c               |    8 +-
 net/netfilter/nf_conntrack_netlink.c           |  177 ++++++-
 net/netfilter/nf_conntrack_pptp.c              |   17 +-
 net/netfilter/nf_conntrack_proto_gre.c         |   16 +-
 net/netfilter/nf_conntrack_sane.c              |   12 +-
 net/netfilter/nf_conntrack_sip.c               |   32 +-
 net/netfilter/nf_conntrack_tftp.c              |    8 +-
 net/netfilter/nfnetlink_cthelper.c             |  674 ++++++++++++++++++++++++
 net/netfilter/nfnetlink_queue.c                |   58 +-
 net/netfilter/xt_CT.c                          |   44 +-
 39 files changed, 1247 insertions(+), 181 deletions(-)
 create mode 100644 include/linux/netfilter/nfnetlink_cthelper.h
 create mode 100644 net/netfilter/nfnetlink_cthelper.c

-- 
1.7.10

