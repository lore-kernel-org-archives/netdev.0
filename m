From: pablo@netfilter.org
Subject: [PATCH 00/16] netfilter updates for net-next
Date: Mon, 24 Sep 2012 21:19:12 +0200
Message-ID: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58064 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756193Ab2IXTUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 15:20:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

This patchset contains updates for your net-next tree, they are:

* Mostly fixes for the recently pushed IPv6 NAT support:

- Fix crash while removing nf_nat modules from Patrick McHardy.
- Fix unbalanced rcu_read_unlock from Ulrich Weber.
- Merge NETMAP and REDIRECT into one single xt_target module, from
  Jan Engelhardt.
- Fix Kconfig for IPv6 NAT, which allows inconsistent configurations,
  from myself.

* Updates for ipset, all of the from Jozsef Kadlecsik:

- Add the new "nomatch" option to obtain reverse set matching.
- Support for /0 CIDR in hash:net,iface set type.
- One non-critical fix for a rare crash due to pass really
  wrong configuration parameters.
- Coding style cleanups.
- Sparse fixes.
- Add set revision supported via modinfo.i

* One extension for the xt_time match, to support matching during
  the transition between two days with one single rule, from
  Florian Westphal.

* Fix maximum packet length supported by nfnetlink_queue and add
  NFQA_CAP_LEN attribute, from myself.

You can notice that this batch contains a couple of fixes that may
go to 3.6-rc but I don't consider them critical to push them:

* The ipset fix for the /0 cidr case, which is triggered with one
  inconsistent command line invocation of ipset.

* The nfnetlink_queue maximum packet length supported since it requires
  the new NFQA_CAP_LEN attribute to provide a full workaround for the
  described problem.

You can pull these changes from:

git://1984.lsi.us.es/nf-next master

Thanks!

Florian Westphal (1):
  netfilter: xt_time: add support to ignore day transition

Jan Engelhardt (2):
  netfilter: combine ipt_NETMAP and ip6t_NETMAP
  netfilter: combine ipt_REDIRECT and ip6t_REDIRECT

Jozsef Kadlecsik (7):
  netfilter: ipset: Fix sparse warnings "incorrect type in assignment"
  netfilter: ipset: Check and reject crazy /0 input parameters
  netfilter: ipset: Rewrite cidr book keeping to handle /0
  netfilter: ipset: Add /0 network support to hash:net,iface type
  netfilter: ipset: Include supported revisions in module description
  netfilter: ipset: Coding style fixes
  netfilter: ipset: Support to match elements marked with "nomatch"

Pablo Neira Ayuso (4):
  netfilter: fix IPv6 NAT dependencies in Kconfig
  netfilter: nf_ct_ftp: add sequence tracking pickup facility for injected entries
  netfilter: nfnetlink_queue: fix maximum packet length to userspace
  netfilter: nfnetlink_queue: add NFQA_CAP_LEN attribute

Patrick McHardy (1):
  netfilter: nf_nat: fix oops when unloading protocol modules

Ulrich Weber (1):
  netfilter: nf_nat: remove obsolete rcu_read_unlock call

 include/linux/netfilter/ipset/ip_set.h       |   15 +-
 include/linux/netfilter/ipset/ip_set_ahash.h |  106 +++++++-------
 include/linux/netfilter/nf_conntrack_ftp.h   |    6 +-
 include/linux/netfilter/nfnetlink_queue.h    |    1 +
 include/linux/netfilter/xt_time.h            |    5 +
 net/ipv4/netfilter/Kconfig                   |   23 ++--
 net/ipv4/netfilter/Makefile                  |    2 -
 net/ipv4/netfilter/ipt_NETMAP.c              |  101 --------------
 net/ipv4/netfilter/ipt_REDIRECT.c            |  113 ---------------
 net/ipv6/netfilter/Kconfig                   |   91 +++++-------
 net/ipv6/netfilter/Makefile                  |    2 -
 net/ipv6/netfilter/ip6t_NETMAP.c             |   94 -------------
 net/ipv6/netfilter/ip6t_REDIRECT.c           |   98 -------------
 net/netfilter/Kconfig                        |   21 +++
 net/netfilter/Makefile                       |    2 +
 net/netfilter/ipset/ip_set_bitmap_ip.c       |   19 ++-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |   18 ++-
 net/netfilter/ipset/ip_set_bitmap_port.c     |    9 +-
 net/netfilter/ipset/ip_set_core.c            |   15 +-
 net/netfilter/ipset/ip_set_hash_ip.c         |   15 +-
 net/netfilter/ipset/ip_set_hash_ipport.c     |   24 ++--
 net/netfilter/ipset/ip_set_hash_ipportip.c   |   24 ++--
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   47 ++++---
 net/netfilter/ipset/ip_set_hash_net.c        |   25 ++--
 net/netfilter/ipset/ip_set_hash_netiface.c   |   66 ++++-----
 net/netfilter/ipset/ip_set_hash_netport.c    |   36 ++---
 net/netfilter/ipset/ip_set_list_set.c        |    9 +-
 net/netfilter/nf_conntrack_core.c            |    2 +
 net/netfilter/nf_conntrack_ftp.c             |   21 +++
 net/netfilter/nf_conntrack_netlink.c         |    4 +-
 net/netfilter/nf_nat_core.c                  |    6 +-
 net/netfilter/nfnetlink_cthelper.c           |    3 +
 net/netfilter/nfnetlink_queue_core.c         |   19 ++-
 net/netfilter/xt_NETMAP.c                    |  165 ++++++++++++++++++++++
 net/netfilter/xt_REDIRECT.c                  |  190 ++++++++++++++++++++++++++
 net/netfilter/xt_set.c                       |   22 +++
 net/netfilter/xt_time.c                      |   24 +++-
 37 files changed, 773 insertions(+), 670 deletions(-)
 delete mode 100644 net/ipv4/netfilter/ipt_NETMAP.c
 delete mode 100644 net/ipv4/netfilter/ipt_REDIRECT.c
 delete mode 100644 net/ipv6/netfilter/ip6t_NETMAP.c
 delete mode 100644 net/ipv6/netfilter/ip6t_REDIRECT.c
 create mode 100644 net/netfilter/xt_NETMAP.c
 create mode 100644 net/netfilter/xt_REDIRECT.c

-- 
1.7.10.4
