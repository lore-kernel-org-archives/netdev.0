From: pablo@netfilter.org
Subject: [PATCH 00/10] netfilter updates for net-next (batch 1)
Date: Thu, 23 Aug 2012 01:38:36 +0200
Message-ID: <1345678726-3109-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

This is the first batch of Netfilter and IPVS updates for your
net-next tree. Mostly cleanups for the Netfilter side. They are:

* Remove unnecessary RTNL locking now that we have support
  for namespace in nf_conntrack, from Patrick McHardy.

* Cleanup to eliminate unnecessary goto in the initialization
  path of several Netfilter tables, from Jean Sacren.

* Another cleanup from Wu Fengguang, this time to PTR_RET instead
  of if IS_ERR then return PTR_ERR.

* Use list_for_each_entry_continue_rcu in nf_iterate, from
  Michael Wang.

* Add pmtu_disc sysctl option to disable PMTU in their tunneling
  transmitter, from Julian Anastasov.

* Generalize application protocol registration in IPVS and modify
  IPVS FTP helper to use it, from Julian Anastasov.

* update Kconfig. The IPVS FTP helper depends on the Netfilter FTP
  helper for NAT support, from Julian Anastasov.

* Add logic to update PMTU for IPIP packets in IPVS, again
  from Julian Anastasov.

* A couple of sparse warning fixes for IPVS and Netfilter from
  Claudiu Ghioc and Patrick McHardy respectively.

Patrick's IPv6 NAT changes will follow after this batch, I need
to flush this batch first before refreshing my tree.

You can pull these changes from:

git://1984.lsi.us.es/nf-next

Thanks!

Claudiu Ghioc (1):
  ipvs: fixed sparse warning

Jean Sacren (1):
  netfilter: remove unnecessary goto statement for error recovery

Julian Anastasov (4):
  ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper
  ipvs: generalize app registration in netns
  ipvs: implement passive PMTUD for IPIP packets
  ipvs: add pmtu_disc option to disable IP DF for TUN packets

Michael Wang (1):
  netfilter: replace list_for_each_continue_rcu with new interface

Patrick McHardy (2):
  netfilter: sparse endian fixes
  netfilter: nf_conntrack: remove unnecessary RTNL locking

Wu Fengguang (1):
  netfilter: PTR_RET can be used

 include/net/ip_vs.h                    |   16 ++++--
 net/bridge/netfilter/ebtable_filter.c  |    4 +-
 net/bridge/netfilter/ebtable_nat.c     |    4 +-
 net/ipv4/netfilter/iptable_filter.c    |   10 +---
 net/ipv4/netfilter/iptable_mangle.c    |   10 +---
 net/ipv4/netfilter/iptable_raw.c       |   10 +---
 net/ipv4/netfilter/iptable_security.c  |    5 +-
 net/ipv6/netfilter/ip6table_filter.c   |    4 +-
 net/ipv6/netfilter/ip6table_mangle.c   |    4 +-
 net/ipv6/netfilter/ip6table_raw.c      |    4 +-
 net/ipv6/netfilter/ip6table_security.c |    5 +-
 net/netfilter/core.c                   |   10 ++--
 net/netfilter/ipvs/Kconfig             |    3 +-
 net/netfilter/ipvs/ip_vs_app.c         |   58 ++++++++++++++++------
 net/netfilter/ipvs/ip_vs_core.c        |   76 +++++++++++++++++++++++++++--
 net/netfilter/ipvs/ip_vs_ctl.c         |   16 ++++--
 net/netfilter/ipvs/ip_vs_ftp.c         |   21 ++------
 net/netfilter/ipvs/ip_vs_xmit.c        |   83 ++++++++++++++++++++++----------
 net/netfilter/nf_conntrack_proto.c     |    5 --
 net/netfilter/nfnetlink_acct.c         |    4 +-
 net/netfilter/nfnetlink_cthelper.c     |    2 +-
 net/netfilter/xt_NFQUEUE.c             |    8 +--
 net/netfilter/xt_osf.c                 |    2 +-
 23 files changed, 232 insertions(+), 132 deletions(-)

-- 
1.7.10.4

