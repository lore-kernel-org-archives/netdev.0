From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/31: netfilter 2.6.32 update
Date: Thu, 10 Sep 2009 18:11:46 +0200 (MEST)
Message-ID: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64615 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbZIJQLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:11:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following is my netfilter update for 2.6.32, containing:

- the scheduled removal of old x_tables match and target revisions from Jan

- the scheduled removal of old redirecting ip_tables header files from Jan

- x_tables cleanups and smaller improvements from Jan

- SCTP support for SO_ORIGINAL_DST from Rafael Laufer

- handling of ICMPv6 messages in IPVS from Julius Volz

- a patch to log packets dropped by conntrack helpers from myself

- patches to constify netlink message attributes in netfilter from myself

- a fix for bridge netfilter in_device refcount leaks from Eric

- a fix for conntrack cleanup in non-init namespaces from Alexey

- a fix for an ebt_ulog inverted return value from myself

- a fix for atomic operations in IPVS from Simon

- a fix for a read outside array bounds in ip6t_eui from myself

- a fix for inverted logic for persistent NAT mappings from Maximilian Engelhardt

Most of the fixes are for regressions, I'll pass all those on to -stable
once the patches hit mainline.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


 Documentation/feature-removal-schedule.txt     |   25 ----
 include/linux/netfilter/nfnetlink.h            |    3 +-
 include/linux/netfilter/x_tables.h             |    4 +-
 include/linux/netfilter/xt_CONNMARK.h          |    6 -
 include/linux/netfilter/xt_MARK.h              |   17 ---
 include/linux/netfilter/xt_connmark.h          |    5 -
 include/linux/netfilter/xt_conntrack.h         |   36 -----
 include/linux/netfilter/xt_mark.h              |    5 -
 include/linux/netfilter_arp/arp_tables.h       |    2 +-
 include/linux/netfilter_bridge/ebtables.h      |    2 +-
 include/linux/netfilter_ipv4/Kbuild            |   32 -----
 include/linux/netfilter_ipv4/ip_tables.h       |    2 +-
 include/linux/netfilter_ipv4/ipt_CLASSIFY.h    |    7 -
 include/linux/netfilter_ipv4/ipt_CONNMARK.h    |   19 ---
 include/linux/netfilter_ipv4/ipt_DSCP.h        |   18 ---
 include/linux/netfilter_ipv4/ipt_ECN.h         |    4 +-
 include/linux/netfilter_ipv4/ipt_MARK.h        |   18 ---
 include/linux/netfilter_ipv4/ipt_NFQUEUE.h     |   16 ---
 include/linux/netfilter_ipv4/ipt_TCPMSS.h      |    9 --
 include/linux/netfilter_ipv4/ipt_TOS.h         |   12 --
 include/linux/netfilter_ipv4/ipt_comment.h     |   10 --
 include/linux/netfilter_ipv4/ipt_connbytes.h   |   18 ---
 include/linux/netfilter_ipv4/ipt_connmark.h    |    7 -
 include/linux/netfilter_ipv4/ipt_conntrack.h   |   28 ----
 include/linux/netfilter_ipv4/ipt_dccp.h        |   15 --
 include/linux/netfilter_ipv4/ipt_dscp.h        |   21 ---
 include/linux/netfilter_ipv4/ipt_ecn.h         |    4 +-
 include/linux/netfilter_ipv4/ipt_esp.h         |   10 --
 include/linux/netfilter_ipv4/ipt_hashlimit.h   |   14 --
 include/linux/netfilter_ipv4/ipt_helper.h      |    7 -
 include/linux/netfilter_ipv4/ipt_iprange.h     |   21 ---
 include/linux/netfilter_ipv4/ipt_length.h      |    7 -
 include/linux/netfilter_ipv4/ipt_limit.h       |    8 -
 include/linux/netfilter_ipv4/ipt_mac.h         |    7 -
 include/linux/netfilter_ipv4/ipt_mark.h        |    9 --
 include/linux/netfilter_ipv4/ipt_multiport.h   |   15 --
 include/linux/netfilter_ipv4/ipt_owner.h       |   20 ---
 include/linux/netfilter_ipv4/ipt_physdev.h     |   17 ---
 include/linux/netfilter_ipv4/ipt_pkttype.h     |    7 -
 include/linux/netfilter_ipv4/ipt_policy.h      |   23 ----
 include/linux/netfilter_ipv4/ipt_recent.h      |   21 ---
 include/linux/netfilter_ipv4/ipt_sctp.h        |  105 ---------------
 include/linux/netfilter_ipv4/ipt_state.h       |   15 --
 include/linux/netfilter_ipv4/ipt_string.h      |   10 --
 include/linux/netfilter_ipv4/ipt_tcpmss.h      |    7 -
 include/linux/netfilter_ipv4/ipt_tos.h         |   13 --
 include/linux/netfilter_ipv6/Kbuild            |   12 +--
 include/linux/netfilter_ipv6/ip6_tables.h      |    2 +-
 include/linux/netfilter_ipv6/ip6t_MARK.h       |    9 --
 include/linux/netfilter_ipv6/ip6t_esp.h        |   10 --
 include/linux/netfilter_ipv6/ip6t_length.h     |    8 -
 include/linux/netfilter_ipv6/ip6t_limit.h      |    8 -
 include/linux/netfilter_ipv6/ip6t_mac.h        |    7 -
 include/linux/netfilter_ipv6/ip6t_mark.h       |    9 --
 include/linux/netfilter_ipv6/ip6t_multiport.h  |   14 --
 include/linux/netfilter_ipv6/ip6t_owner.h      |   18 ---
 include/linux/netfilter_ipv6/ip6t_physdev.h    |   17 ---
 include/linux/netfilter_ipv6/ip6t_policy.h     |   23 ----
 include/linux/netlink.h                        |   15 +-
 include/net/netfilter/nf_nat_core.h            |    2 +-
 include/net/netlink.h                          |    4 +-
 include/net/rtnetlink.h                        |    2 +-
 net/bridge/br_netfilter.c                      |    2 +-
 net/bridge/netfilter/ebt_log.c                 |   29 +---
 net/bridge/netfilter/ebt_ulog.c                |    2 +-
 net/bridge/netfilter/ebtable_broute.c          |    2 +-
 net/bridge/netfilter/ebtable_filter.c          |    8 +-
 net/bridge/netfilter/ebtable_nat.c             |    6 +-
 net/bridge/netfilter/ebtables.c                |   13 +-
 net/ipv4/netfilter/arp_tables.c                |   47 +++++--
 net/ipv4/netfilter/arptable_filter.c           |    4 +-
 net/ipv4/netfilter/ip_tables.c                 |   51 +++++---
 net/ipv4/netfilter/iptable_filter.c            |   10 +-
 net/ipv4/netfilter/iptable_mangle.c            |   16 +-
 net/ipv4/netfilter/iptable_raw.c               |   10 +-
 net/ipv4/netfilter/iptable_security.c          |   12 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   22 ++--
 net/ipv4/netfilter/nf_nat_core.c               |    8 +-
 net/ipv4/netfilter/nf_nat_rule.c               |    6 +-
 net/ipv4/netfilter/nf_nat_standalone.c         |    8 +-
 net/ipv6/netfilter/ip6_tables.c                |   48 +++++--
 net/ipv6/netfilter/ip6t_eui64.c                |    9 +-
 net/ipv6/netfilter/ip6table_filter.c           |   10 +-
 net/ipv6/netfilter/ip6table_mangle.c           |   16 +-
 net/ipv6/netfilter/ip6table_raw.c              |   10 +-
 net/ipv6/netfilter/ip6table_security.c         |   12 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   18 ++-
 net/netfilter/ipvs/ip_vs_core.c                |   29 +++--
 net/netfilter/ipvs/ip_vs_wrr.c                 |    7 +-
 net/netfilter/nf_conntrack_core.c              |    8 +-
 net/netfilter/nf_conntrack_netlink.c           |   54 +++++---
 net/netfilter/nfnetlink.c                      |    2 +-
 net/netfilter/nfnetlink_log.c                  |    6 +-
 net/netfilter/nfnetlink_queue.c                |    9 +-
 net/netfilter/x_tables.c                       |    7 +-
 net/netfilter/xt_CONNMARK.c                    |  134 ++------------------
 net/netfilter/xt_DSCP.c                        |   46 -------
 net/netfilter/xt_MARK.c                        |  163 ++----------------------
 net/netfilter/xt_connmark.c                    |  101 ++-------------
 net/netfilter/xt_conntrack.c                   |  155 +----------------------
 net/netfilter/xt_dscp.c                        |   17 ---
 net/netfilter/xt_iprange.c                     |   45 +------
 net/netfilter/xt_mark.c                        |   86 ++-----------
 net/netfilter/xt_osf.c                         |    6 +-
 net/netfilter/xt_owner.c                       |  130 ++-----------------
 net/netlink/af_netlink.c                       |    2 +-
 net/sched/act_api.c                            |    2 +-
 107 files changed, 373 insertions(+), 1856 deletions(-)
 delete mode 100644 include/linux/netfilter_ipv4/ipt_CLASSIFY.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_CONNMARK.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_DSCP.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_MARK.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_NFQUEUE.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_TCPMSS.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_TOS.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_comment.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_connbytes.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_connmark.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_conntrack.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_dccp.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_dscp.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_esp.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_hashlimit.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_helper.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_iprange.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_length.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_limit.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_mac.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_mark.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_multiport.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_owner.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_physdev.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_pkttype.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_policy.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_recent.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_sctp.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_state.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_string.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_tcpmss.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_tos.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_MARK.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_esp.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_length.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_limit.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_mac.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_mark.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_multiport.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_owner.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_physdev.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_policy.h

Alexey Dobriyan (1):
      netfilter: nf_conntrack: netns fix re reliable conntrack event delivery

Eric Dumazet (1):
      netfilter: bridge: refcount fix

Jan Engelhardt (19):
      netfilter: xtables: remove xt_TOS v0
      netfilter: xtables: remove xt_CONNMARK v0
      netfilter: xtables: remove xt_MARK v0, v1
      netfilter: xtables: remove xt_connmark v0
      netfilter: xtables: remove xt_conntrack v0
      netfilter: xtables: remove xt_iprange v0
      netfilter: xtables: remove xt_mark v0
      netfilter: xtables: remove xt_owner v0
      netfilter: xtables: remove redirecting header files
      netfilter: conntrack: switch hook PFs to nfproto
      netfilter: xtables: switch hook PFs to nfproto
      netfilter: xtables: switch table AFs to nfproto
      netfilter: xtables: realign struct xt_target_param
      netfilter: iptables: remove unused datalen variable
      netfilter: xtables: use memcmp in unconditional check
      netfilter: xtables: ignore unassigned hooks in check_entry_size_and_hooks
      netfilter: xtables: check for unconditionality of policies
      netfilter: xtables: check for standard verdicts in policies
      netfilter: xtables: mark initial tables constant

Julius Volz (1):
      IPVS: Add handling of incoming ICMPV6 messages

Maximilian Engelhardt (1):
      netfilter: nf_nat: fix inverted logic for persistent NAT mappings

Patrick McHardy (6):
      Merge branch 'master' of git://dev.medozas.de/linux
      netfilter: nf_conntrack: log packets dropped by helpers
      netlink: constify nlmsghdr arguments
      netfilter: nfnetlink: constify message attributes and headers
      netfilter: ip6t_eui: fix read outside array bounds
      netfilter: ebt_ulog: fix checkentry return value

Rafael Laufer (1):
      netfilter: nf_conntrack: add SCTP support for SO_ORIGINAL_DST

Simon Horman (1):
      ipvs: Use atomic operations atomicly

Tobias Klauser (1):
      netfilter: ebtables: Use %pM conversion specifier
