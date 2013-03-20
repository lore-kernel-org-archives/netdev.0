From: pablo@netfilter.org
Subject: [PATCH 0/7] netfilter fixes for 3.9-rc
Date: Wed, 20 Mar 2013 11:49:27 +0100
Message-ID: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51242 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752620Ab3CTKtp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 06:49:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains 7 Netfilter/IPVS fixes for 3.9-rc, they are:

* Restrict IPv6 stateless NPT targets to the mangle table. Many users are
  complaining that this target does not work in the nat table, which is the
  wrong table for it, from Florian Westphal.

* Fix possible use before initialization in the netns init path of several
  conntrack protocol trackers (introduced recently while improving conntrack
  netns support), from Gao Feng.

* Fix incorrect initialization of copy_range in nfnetlink_queue, spotted
  by Eric Dumazet during the NFWS2013, patch from myself.

* Fix wrong calculation of next SCTP chunk in IPVS, from Julian Anastasov.

* Remove rcu_read_lock section in IPVS while calling ipv4_update_pmtu
  not required anymore after change introduced in 3.7, again from Julian.

* Fix SYN looping in IPVS state sync if the backup is used a real server
  in DR/TUN modes, this required a new /proc entry to disable the director
  function when acting as backup, also from Julian.

* Remove leftover IP_NF_QUEUE Kconfig after ip_queue removal, noted by
  Paul Bolle.

You can pull these changes from:

git://1984.lsi.us.es/nf master

Thanks!

Florian Westphal (1):
  netfilter: ip6t_NPT: restrict to mangle table

Gao feng (1):
  netfilter: nf_conntrack: register pernet subsystem before register L4 proto

Julian Anastasov (3):
  ipvs: fix sctp chunk length order
  ipvs: add backup_only flag to avoid loops
  ipvs: remove extra rcu lock

Pablo Neira Ayuso (1):
  netfilter: nfnetlink_queue: fix incorrect initialization of copy range field

Paul Bolle (1):
  netfilter: remove unused "config IP_NF_QUEUE"

 Documentation/networking/ipvs-sysctl.txt   |    7 +++++++
 include/net/ip_vs.h                        |   12 ++++++++++++
 net/ipv4/netfilter/Kconfig                 |   13 -------------
 net/ipv6/netfilter/ip6t_NPT.c              |    2 ++
 net/netfilter/ipvs/ip_vs_core.c            |   14 ++++++++------
 net/netfilter/ipvs/ip_vs_ctl.c             |    7 +++++++
 net/netfilter/ipvs/ip_vs_proto_sctp.c      |   16 +++++++++-------
 net/netfilter/nf_conntrack_proto_dccp.c    |   12 ++++++------
 net/netfilter/nf_conntrack_proto_gre.c     |   12 ++++++------
 net/netfilter/nf_conntrack_proto_sctp.c    |   12 ++++++------
 net/netfilter/nf_conntrack_proto_udplite.c |   12 ++++++------
 net/netfilter/nfnetlink_queue_core.c       |    2 +-
 12 files changed, 70 insertions(+), 51 deletions(-)

-- 
1.7.10.4
