From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] netfilter fixes for net
Date: Sat,  5 Apr 2014 18:21:14 +0200
Message-ID: <1396714874-4426-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35393 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753083AbaDEQVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2014 12:21:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending the cover letter, sent the wrong template, sorry

-o-

Hi,

The following patchset contains Netfilter fixes for your net tree, they
are:

* Use 16-bits offset and length fields instead of 8-bits in the conntrack
  extension to avoid an overflow when many conntrack extension are used,
  from Andrey Vagin.

* Allow to use cgroup match from LOCAL_IN, there is no apparent reason
  for not allowing this, from Alexey Perevalov.

* Fix build of the connlimit match after recent changes to let it scale
  up that result in a divide by zero compilation error in UP, from
  Florian Westphal.

* Move the lock out of the structure connlimit_data to avoid a false
  sharing spotted by Eric Dumazet and Jesper D. Brouer, this needed as
  part of the recent connlimit scalability improvements, also from
  Florian Westphal.

* Add missing module aliases in xt_osf to fix loading of rules using
  this match, from Kirill Tkhai.

* Restrict set names in nf_tables to 15 characters instead of silently
  trimming them off, from me.

* Fix wrong format in nf_tables request module call for chain types,
  spotted by Florian Westphal, patch from me.

* Fix crash in xtables when it fails to copy the counters back to userspace
  after having replaced the table already.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks.

----------------------------------------------------------------

The following changes since commit e33d0ba8047b049c9262fdb1fcafb93cb52ceceb:

  net-gro: reset skb->truesize in napi_reuse_skb() (2014-04-03 16:17:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to c58dd2dd443c26d856a168db108a0cd11c285bf3:

  netfilter: Can't fail and free after table replacement (2014-04-05 17:46:22 +0200)

----------------------------------------------------------------
Alexey Perevalov (1):
      netfilter: x_tables: allow to use cgroup match for LOCAL_IN nf hooks

Andrey Vagin (1):
      netfilter: nf_conntrack: reserve two bytes for nf_ct_ext->len

Florian Westphal (2):
      netfilter: connlimit: fix UP build
      netfilter: connlimit: move lock array out of struct connlimit_data

Kirill Tkhai (1):
      netfilter: Add {ipt,ip6t}_osf aliases for xt_osf

Pablo Neira Ayuso (2):
      netfilter: nf_tables: set names cannot be larger than 15 bytes
      netfilter: nf_tables: fix wrong format in request_module()

Thomas Graf (1):
      netfilter: Can't fail and free after table replacement

 include/net/netfilter/nf_conntrack_extend.h |    4 ++--
 net/bridge/netfilter/ebtables.c             |    5 ++---
 net/ipv4/netfilter/arp_tables.c             |    6 ++++--
 net/ipv4/netfilter/ip_tables.c              |    6 ++++--
 net/ipv6/netfilter/ip6_tables.c             |    6 ++++--
 net/netfilter/nf_tables_api.c               |    7 ++++---
 net/netfilter/xt_cgroup.c                   |    3 ++-
 net/netfilter/xt_connlimit.c                |   25 ++++++++++++++++---------
 net/netfilter/xt_osf.c                      |    2 ++
 9 files changed, 40 insertions(+), 24 deletions(-)
