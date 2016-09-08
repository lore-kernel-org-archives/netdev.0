From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2016-09-08
Date: Thu, 8 Sep 2016 07:54:35 +0200
Message-ID: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36341 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752925AbcIHGvY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Constify the xfrm_replay structures. From Julia Lawall

2) Protect xfrm state hash tables with rcu, lookups
   can be done now without acquiring xfrm_state_lock.
   From Florian Westphal.

3) Protect xfrm policy hash tables with rcu, lookups
   can be done now without acquiring xfrm_policy_lock.
   From Florian Westphal.

4) We don't need to have a garbage collector list per
   namespace anymore, so use a global one instead.
   From Florian Westphal.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 0184165b2f42c4b032da9dd11546bfbaeb5afd4e:

  ravb: add sleep PM suspend/resume support (2016-08-09 16:16:08 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 35db57bbc4b7ab810bba6e6d6954a0faf5a842cf:

  xfrm: state: remove per-netns gc task (2016-08-24 13:16:06 +0200)

----------------------------------------------------------------
Florian Westphal (15):
      xfrm: state: use hlist_for_each_entry_rcu helper
      xfrm: state: use atomic_inc_not_zero to increment refcount
      xfrm: state: delay freeing until rcu grace period has elapsed
      xfrm: state: add sequence count to detect hash resizes
      xfrm: state: use rcu_deref and assign_pointer helpers
      xfrm: state: don't use lock anymore unless acquire operation is needed
      xfrm: policy: use rcu versions for iteration and list add/del
      xfrm: policy: prepare policy_bydst hash for rcu lookups
      xfrm: policy: add sequence count to sync with hash resize
      xfrm: policy: use atomic_inc_not_zero in rcu section
      xfrm: policy: make xfrm_policy_lookup_bytype lockless
      xfrm: policy: only use rcu in xfrm_sk_policy_lookup
      xfrm: policy: don't acquire policy lock in xfrm_spd_getinfo
      xfrm: policy: convert policy_lock to spinlock
      xfrm: state: remove per-netns gc task

Julia Lawall (1):
      xfrm: constify xfrm_replay structures

Steffen Klassert (1):
      xfrm: Fix xfrm_policy_lock imbalance

 include/net/netns/xfrm.h |  12 ++--
 include/net/xfrm.h       |   2 +-
 net/xfrm/xfrm_policy.c   | 145 ++++++++++++++++++++++++++++-------------------
 net/xfrm/xfrm_replay.c   |   6 +-
 net/xfrm/xfrm_state.c    | 121 +++++++++++++++++++++++++--------------
 5 files changed, 173 insertions(+), 113 deletions(-)
