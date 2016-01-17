From: Antonio Quartulli <a@unstable.cc>
Subject: pull request [net]: batman-adv 20160117
Date: Sun, 17 Jan 2016 13:24:33 +0800
Message-ID: <1453008281-15396-1-git-send-email-a__44203.1303573914$1453008453$gmane$org@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:30723 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798AbcAQF0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jan 2016 00:26:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have a bunch of patches intended for net.

This patchset is provided by Sven Eckelmann and it is basically
fixing 2 major issues that exist in several parts of the code -
that is why we have 8 patches.

The first bugfix (patch 1 and 2) is preventing call_rcu from
being invoked recursively. This would deceive any user waiting
on rcu_barrier() because the latter won't be able to wait for
the nested invocation thus triggering any sort of undefined
behaviours.

The second bugfix (patches from 3 to 8) prevents the code from
freeing rcu protected objects without waiting for the proper grace
period. This issue can potentially lead to wrong memory access
and thus kernel crashes.

Unfortunately this bogus code pattern was copy/pasted
all around the place when developing new features, therefore
Sven diligently created several patches to address each component
independently.



Given that such bugs were introduced quite some time ago, all
the patches except patch 5 should be considered for submission
to stable.



Please pull or let me know of any issue!
Thanks a lot,
	Antonio





The following changes since commit 6c3f5aef1159a278b54642ebc0bbb5cdab7630cf:

  bna: fix Rx data corruption with VLAN stripping enabled and MTU > 4096 (2016-01-15 21:49:25 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 42eff6a617e23b691f8e4467f4687ed7245a92db:

  batman-adv: Drop immediate orig_node free function (2016-01-16 22:50:00 +0800)

----------------------------------------------------------------
Included changes:
- avoid recursive invocations of call_rcu() which would fool users waiting on
  rcu_barrier()
- prevent immediate kfree of objects used in rcu protected contexts

----------------------------------------------------------------
Sven Eckelmann (8):
      batman-adv: Avoid recursive call_rcu for batadv_bla_claim
      batman-adv: Avoid recursive call_rcu for batadv_nc_node
      batman-adv: Drop immediate batadv_orig_ifinfo free function
      batman-adv: Drop immediate batadv_neigh_node free function
      batman-adv: Drop immediate batadv_hardif_neigh_node free function
      batman-adv: Drop immediate neigh_ifinfo free function
      batman-adv: Drop immediate batadv_hard_iface free function
      batman-adv: Drop immediate orig_node free function

 net/batman-adv/bridge_loop_avoidance.c |  10 +-
 net/batman-adv/hard-interface.h        |  12 --
 net/batman-adv/network-coding.c        |  19 ++--
 net/batman-adv/originator.c            | 196 ++++++++++++---------------------
 net/batman-adv/originator.h            |   1 -
 net/batman-adv/translation-table.c     |  28 +++--
 6 files changed, 94 insertions(+), 172 deletions(-)
