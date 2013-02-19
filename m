From: pablo@netfilter.org
Subject: [PATCH 0/7] netfilter updates for net-next
Date: Tue, 19 Feb 2013 01:10:44 +0100
Message-ID: <1361232651-5626-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:45746 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756799Ab3BSALL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 19:11:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contain updates for your net-next tree, they are:

* Fix (for just added) connlabel dependencies, from Florian Westphal.

* Add aliasing support for conntrack, thus users can either use -m state
  or -m conntrack from iptables while using the same kernel module, from
  Jozsef Kadlecsik.

* Some code refactoring for the CT target to merge common code in
  revision 0 and 1, from myself.

* Add aliasing support for CT, based on patch from Jozsef Kadlecsik.

* Add one mutex per nfnetlink subsystem, from myself.

* Improved logging for packets that are dropped by helpers, from myself.

You can pull these changes from:

git://1984.lsi.us.es/nf-next master

Thanks!

Florian Westphal (1):
  netfilter: fix missing dependencies for NETFILTER_XT_MATCH_CONNLABEL

Jozsef Kadlecsik (1):
  netfilter: xt_conntrack: Add flag to support aliases

Pablo Neira Ayuso (4):
  netfilter: xt_CT: merge common code of revision 0 and 1
  netfilter: xt_CT: add alias flag
  netfilter: nfnetlink: add mutex per subsystem
  netfilter: nf_ct_helper: better logging for dropped packets

Reese Moore (1):
  netfilter: nf_ct_pptp: Fix comment referring to incorrect RFC

 include/linux/netfilter/nfnetlink.h            |    4 +-
 include/net/netfilter/nf_conntrack_helper.h    |    3 +
 include/uapi/linux/netfilter/xt_CT.h           |    6 +-
 include/uapi/linux/netfilter/xt_conntrack.h    |    1 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   10 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    8 +-
 net/netfilter/Kconfig                          |    1 +
 net/netfilter/ipset/ip_set_core.c              |   26 ++--
 net/netfilter/nf_conntrack_amanda.c            |    5 +-
 net/netfilter/nf_conntrack_ftp.c               |   10 +-
 net/netfilter/nf_conntrack_h323_main.c         |    6 +-
 net/netfilter/nf_conntrack_helper.c            |   18 +++
 net/netfilter/nf_conntrack_irc.c               |    7 +-
 net/netfilter/nf_conntrack_netlink.c           |   12 +-
 net/netfilter/nf_conntrack_pptp.c              |    2 +-
 net/netfilter/nf_conntrack_sane.c              |    5 +-
 net/netfilter/nf_conntrack_sip.c               |   80 ++++++++---
 net/netfilter/nf_conntrack_tftp.c              |    8 +-
 net/netfilter/nf_nat_amanda.c                  |    8 +-
 net/netfilter/nf_nat_ftp.c                     |    5 +-
 net/netfilter/nf_nat_irc.c                     |    8 +-
 net/netfilter/nf_nat_sip.c                     |   49 +++++--
 net/netfilter/nf_nat_tftp.c                    |    4 +-
 net/netfilter/nfnetlink.c                      |   52 ++++---
 net/netfilter/xt_CT.c                          |  177 ++++++++++++------------
 25 files changed, 315 insertions(+), 200 deletions(-)

-- 
1.7.10.4
