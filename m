From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/3] netfilter: Use pr_<level> and pr_fmt
Date: Thu, 11 Jun 2009 00:40:19 -0700
Message-ID: <cover.1244705154.git.joe@perches.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many of the calls to netfilter printk calls do not
have KERN_<level> prefixes.

Convert printks with KERN_<level> to pr_<level>
and use pr_info for unprefixed printks.

Remove the function names in printk strings and add
#define pr_fmt(fmt) "%s:%s " fmt, KBUILD_MODNAME, __func__

Added a couple of spelling fixes along the way.

One negative of these patches is that some of the
pr_debug calls have prefixes like "nf_ct_h323:" that
are lost in the conversion.

Joe Perches (3):
  x_tables: Convert printk to pr_err
  net/netfilter: Convert printk uses to pr_<level>
  netfilter h323_asn1.c: convert PRINT to pr_info

 net/netfilter/nf_conntrack_acct.c       |   12 ++-
 net/netfilter/nf_conntrack_amanda.c     |    5 +-
 net/netfilter/nf_conntrack_core.c       |   43 +++++------
 net/netfilter/nf_conntrack_expect.c     |    5 +-
 net/netfilter/nf_conntrack_ftp.c        |   46 ++++++------
 net/netfilter/nf_conntrack_h323_asn1.c  |    3 +-
 net/netfilter/nf_conntrack_h323_main.c  |  123 +++++++++++++++----------------
 net/netfilter/nf_conntrack_helper.c     |    2 +
 net/netfilter/nf_conntrack_irc.c        |   16 ++--
 net/netfilter/nf_conntrack_netlink.c    |   14 ++--
 net/netfilter/nf_conntrack_pptp.c       |    2 +
 net/netfilter/nf_conntrack_proto_gre.c  |    2 +
 net/netfilter/nf_conntrack_proto_sctp.c |    6 +-
 net/netfilter/nf_conntrack_proto_tcp.c  |   28 ++++---
 net/netfilter/nf_conntrack_sane.c       |   20 +++---
 net/netfilter/nf_conntrack_sip.c        |   10 ++-
 net/netfilter/nf_conntrack_standalone.c |    4 +-
 net/netfilter/nf_conntrack_tftp.c       |    6 +-
 net/netfilter/nf_tproxy_core.c          |    2 +
 net/netfilter/nfnetlink.c               |    8 +-
 net/netfilter/nfnetlink_log.c           |    9 ++-
 net/netfilter/nfnetlink_queue.c         |   18 +++--
 net/netfilter/x_tables.c                |   16 ++--
 net/netfilter/xt_CONNMARK.c             |   18 +++--
 net/netfilter/xt_CONNSECMARK.c          |   13 ++-
 net/netfilter/xt_DSCP.c                 |    6 +-
 net/netfilter/xt_HL.c                   |   11 +--
 net/netfilter/xt_LED.c                  |   12 ++--
 net/netfilter/xt_MARK.c                 |    9 +-
 net/netfilter/xt_SECMARK.c              |   23 +++---
 net/netfilter/xt_TCPMSS.c               |   22 +++---
 net/netfilter/xt_cluster.c              |   11 ++-
 net/netfilter/xt_connbytes.c            |    7 +-
 net/netfilter/xt_connlimit.c            |    7 +-
 net/netfilter/xt_connmark.c             |   12 ++-
 net/netfilter/xt_conntrack.c            |    6 +-
 net/netfilter/xt_dscp.c                 |    4 +-
 net/netfilter/xt_hashlimit.c            |   27 +++----
 net/netfilter/xt_helper.c               |    6 +-
 net/netfilter/xt_hl.c                   |    8 +-
 net/netfilter/xt_iprange.c              |    3 +
 net/netfilter/xt_limit.c                |    6 +-
 net/netfilter/xt_mark.c                 |    4 +-
 net/netfilter/xt_osf.c                  |    8 +-
 net/netfilter/xt_owner.c                |   10 +-
 net/netfilter/xt_physdev.c              |    8 +-
 net/netfilter/xt_policy.c               |   13 ++--
 net/netfilter/xt_recent.c               |   12 ++-
 net/netfilter/xt_socket.c               |    5 +-
 net/netfilter/xt_state.c                |    6 +-
 net/netfilter/xt_statistic.c            |    4 +-
 net/netfilter/xt_time.c                 |   16 ++--
 52 files changed, 385 insertions(+), 312 deletions(-)

