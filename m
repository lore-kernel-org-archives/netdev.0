From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 21 Jul 2008 10:58:14 -0700 (PDT)
Message-ID: <20080721.105814.241900308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54877
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbYGUR6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 13:58:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is a collection of the fixes that poured in today,
including your change to use WARN_ON in __netif_schedule()
as well as a 64-bit counter rework in netfilter.

I'm looking at a netconsole and a wireless crash reported
by Ingo.

Please pull, thanks a lot!

The following changes since commit 14b395e35d1afdd8019d11b92e28041fad591b71:
  Linus Torvalds (1):
        Merge branch 'for-2.6.27' of git://linux-nfs.org/~bfields/linux

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Anton Vorontsov (2):
      gianfar: do not touch net queue in adjust_link phylib callback
      ucc_geth: do not touch net queue in adjust_link phylib callback

Changli Gao (1):
      netfilter: nf_nat_core: eliminate useless find_appropriate_src for IP_NAT_RANGE_PROTO_RANDOM

Daniel Lezcano (1):
      pkt_sched: Remove unused variable skb in dev_deactivate_queue function.

David Howells (1):
      netfilter: xt_time: fix time's time_mt()'s use of do_div()

David S. Miller (4):
      atl1: Do not wake queue before queue has been started.
      sunhme: Remove stop/wake TX queue calls in set-multicast-list handler.
      net: Improve simple_tx_hash().
      Revert "pkt_sched: Make default qdisc nonshared-multiqueue safe."

Eric Leblond (1):
      netfilter: nfnetlink_log: send complete hardware header

Herbert Xu (1):
      netfilter: nf_nat_sip: c= is optional for session

Jan Engelhardt (1):
      netfilter: xt_TCPMSS: collapse tcpmss_reverse_mtu{4,6} into one function

Krzysztof Piotr Oledzki (2):
      netlink: add NLA_PUT_BE64 macro
      netfilter: accounting rework: ct_extend + 64bit counters (v4)

Linus Torvalds (1):
      net: In __netif_schedule() use WARN_ON instead of BUG_ON

Micah Dowty (1):
      hdlcdrv: Fix CRC calculation.

Patrick McHardy (1):
      netfilter: nf_conntrack_sctp: fix sparse warnings

 Documentation/feature-removal-schedule.txt         |   10 ++
 Documentation/kernel-parameters.txt                |    7 ++
 drivers/net/atlx/atl1.c                            |    3 +-
 drivers/net/gianfar.c                              |    1 -
 drivers/net/hamradio/hdlcdrv.c                     |    1 +
 drivers/net/sunhme.c                               |    4 -
 drivers/net/ucc_geth.c                             |    1 -
 include/linux/netfilter/nf_conntrack_common.h      |    8 +--
 include/linux/netfilter/nfnetlink_conntrack.h      |    8 +-
 include/linux/netfilter/nfnetlink_log.h            |    3 +
 include/net/netfilter/nf_conntrack.h               |    6 -
 include/net/netfilter/nf_conntrack_acct.h          |   51 ++++++++++
 include/net/netfilter/nf_conntrack_extend.h        |    2 +
 include/net/netlink.h                              |    3 +
 net/core/dev.c                                     |   37 +++++---
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |   18 +---
 net/ipv4/netfilter/nf_nat_core.c                   |    8 +-
 net/ipv4/netfilter/nf_nat_sip.c                    |   38 +++++---
 net/netfilter/Kconfig                              |    9 ++
 net/netfilter/Makefile                             |    2 +-
 net/netfilter/nf_conntrack_acct.c                  |  104 ++++++++++++++++++++
 net/netfilter/nf_conntrack_core.c                  |   39 +++++---
 net/netfilter/nf_conntrack_netlink.c               |   44 ++++-----
 net/netfilter/nf_conntrack_proto_sctp.c            |    8 +-
 net/netfilter/nf_conntrack_standalone.c            |   18 +---
 net/netfilter/nfnetlink_log.c                      |    8 ++
 net/netfilter/xt_TCPMSS.c                          |   42 +++------
 net/netfilter/xt_connbytes.c                       |    8 +-
 net/netfilter/xt_time.c                            |    2 +-
 net/sched/sch_generic.c                            |  102 +++++++++++++++-----
 30 files changed, 411 insertions(+), 184 deletions(-)
 create mode 100644 include/net/netfilter/nf_conntrack_acct.h
 create mode 100644 net/netfilter/nf_conntrack_acct.c
