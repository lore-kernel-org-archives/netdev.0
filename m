From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/10] Netfilter/IPVS fixes for net
Date: Thu, 23 Jul 2015 01:00:42 +0200
Message-ID: <1437606052-5179-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54415 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbbGVWzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 18:55:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains ten Netfilter/IPVS fixes, they are:

1) Address refcount leak when creating an expectation from the ctnetlink
   interface.

2) Fix bug splat in the IDLETIMER target related to sysfs, from Dmitry
   Torokhov.

3) Resolve panic for unreachable route in IPVS with locally generated
   traffic in the output path, from Alex Gartrell.

4) Fix wrong source address in rare cases for tunneled traffic in IPVS,
   from Julian Anastasov.

5) Fix crash if scheduler is changed via ipvsadm -E, again from Julian.

6) Make sure skb->sk is unset for forwarded traffic through IPVS, again from
   Alex Gartrell.

7) Fix crash with IPVS sync protocol v0 and FTP, from Julian.

8) Reset sender cpu for forwarded traffic in IPVS, also from Julian.

9) Allocate template conntracks through kmalloc() to resolve netns dependency
   problems with the conntrack kmem_cache.

10) Fix zones with expectations that clash using the same tuple, from Joe
    Stringer.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit a7d35f9d73e9ffa74a02304b817e579eec632f67:

  bridge: fix potential crash in __netdev_pick_tx() (2015-07-09 22:48:42 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 4b31814d20cbe5cd4ccf18089751e77a04afe4f2:

  netfilter: nf_conntrack: Support expectations in different zones (2015-07-22 17:00:47 +0200)

----------------------------------------------------------------
Alex Gartrell (2):
      ipvs: fix ipv6 route unreach panic
      ipvs: skb_orphan in case of forwarding

Dmitry Torokhov (1):
      netfilter: IDLETIMER: fix lockdep warning

Joe Stringer (1):
      netfilter: nf_conntrack: Support expectations in different zones

Julian Anastasov (4):
      ipvs: do not use random local source address for tunnels
      ipvs: fix crash if scheduler is changed
      ipvs: fix crash with sync protocol v0 and FTP
      ipvs: call skb_sender_cpu_clear

Pablo Neira Ayuso (3):
      netfilter: ctnetlink: put back references to master ct and expect objects
      netfilter: fix netns dependencies with conntrack templates
      Merge tag 'ipvs-fixes-for-v4.2' of https://git.kernel.org/.../horms/ipvs

 include/net/netfilter/nf_conntrack.h |    2 +-
 include/net/netns/conntrack.h        |    1 -
 net/netfilter/ipvs/ip_vs_core.c      |   16 ++++++-
 net/netfilter/ipvs/ip_vs_ctl.c       |   78 +++++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_sched.c     |   12 +++---
 net/netfilter/ipvs/ip_vs_sync.c      |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c      |   41 +++++++++++++++++-
 net/netfilter/nf_conntrack_core.c    |   67 +++++++++++++++++++----------
 net/netfilter/nf_conntrack_expect.c  |    3 +-
 net/netfilter/nf_conntrack_netlink.c |    5 ---
 net/netfilter/nf_synproxy_core.c     |    7 ++-
 net/netfilter/xt_CT.c                |    8 ++--
 net/netfilter/xt_IDLETIMER.c         |    1 +
 13 files changed, 164 insertions(+), 79 deletions(-)
