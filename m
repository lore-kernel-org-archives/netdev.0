From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] netfilter fixes for 3.10-rc5
Date: Mon, 10 Jun 2013 18:07:36 +0200
Message-ID: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains four fixes for Netfilter and one fix
for IPVS, they are:

* Fix data leak to user-space via getsockopt IP_VS_SO_GET_DESTS, from
  Dan Carpenter.

* Fix xt_TCPMSS if no TCP MSS is specified in syn packets, to avoid the
  violation of RFC879, from Phil Oester.

* Fix incomplete dump of objects via nfnetlink_acct and nfnetlink_cttimeout,
  from myself.

* Fix missing HW protocol in packets passed to user-space via NFQUEUE,
  from myself.

You can pull these changes from:

git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 5343a7f8be11951cb3095b91e8e4eb506cfacc0f:

  net_sched: htb: do not mix 1ns and 64ns time units (2013-06-04 17:44:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to a8241c63517ec0b900695daa9003cddc41c536a1:

  ipvs: info leak in __ip_vs_get_dest_entries() (2013-06-10 14:53:00 +0200)

----------------------------------------------------------------
Dan Carpenter (1):
      ipvs: info leak in __ip_vs_get_dest_entries()

Pablo Neira Ayuso (3):
      netfilter: nfnetlink_acct: fix incomplete dumping of objects
      netfilter: nfnetlink_cttimeout: fix incomplete dumping of objects
      netfilter: nfnetlink_queue: fix missing HW protocol

Phil Oester (1):
      netfilter: xt_TCPMSS: Fix violation of RFC879 in absence of MSS option

 net/netfilter/ipvs/ip_vs_ctl.c       |    1 +
 net/netfilter/nfnetlink_acct.c       |    7 +++++--
 net/netfilter/nfnetlink_cttimeout.c  |    7 +++++--
 net/netfilter/nfnetlink_queue_core.c |    6 +++---
 net/netfilter/xt_TCPMSS.c            |    6 ++++++
 5 files changed, 20 insertions(+), 7 deletions(-)
