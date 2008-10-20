From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/07: netfilter fixes
Date: Mon, 20 Oct 2008 11:54:08 +0200 (MEST)
Message-ID: <20081020095408.25670.37455.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52343 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbYJTJyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 05:54:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are some netfilter fixes for 2.6.28:

- the fix for the ctnetlink compilation error reported by Benjamin and Ingo

- removal of an obsolete ctnetlink depenency on NAT

- two fixes for the netfilter protocol value decoupling: use of NFPROTO
  constants in struct netns_xt and use of NFPROTO constants for ARP hooks

- a fix for iprange inverted matching

- a fix for a memory leak in SNMP NAT

- a fix for an oops in recent_seq_start()

The iprange and SNMP NAT patches are also queued for -stable.

Please apply, thanks.


 include/net/netns/x_tables.h           |    4 ++--
 net/bridge/br_netfilter.c              |    2 +-
 net/ipv4/arp.c                         |    4 ++--
 net/ipv4/netfilter/nf_nat_snmp_basic.c |    1 +
 net/netfilter/Kconfig                  |    1 -
 net/netfilter/nf_conntrack_netlink.c   |    2 ++
 net/netfilter/xt_NFQUEUE.c             |    2 +-
 net/netfilter/xt_iprange.c             |    8 ++++----
 net/netfilter/xt_recent.c              |   10 ++++------
 9 files changed, 17 insertions(+), 17 deletions(-)

Alexey Dobriyan (2):
      netfilter: xt_iprange: fix range inversion match
      netfilter: xt_recent: use proc_create_data()

Jan Engelhardt (1):
      netfilter: replace old NF_ARP calls with NFPROTO_ARP

Pablo Neira Ayuso (1):
      netfilter: fix compilation error with NAT=n

Patrick McHardy (2):
      netfilter: ctnetlink: remove obsolete NAT dependency from Kconfig
      netfilter: netns: use NFPROTO_NUMPROTO instead of NUMPROTO for tables array

Ilpo Jarvinen (1):
      netfilter: snmp nat leaks memory in case of failure
