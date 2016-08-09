From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/6] xfrm: convert xfrm_state_find to rcu
Date: Tue,  9 Aug 2016 12:16:03 +0200
Message-ID: <1470737769-30438-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43902 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751414AbcHIKQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:16:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series converts state_by{dst,src,spi} to allow lookups without
holding xfrm_state_lock.

Only xfrm_state_find() is converted here for the (more common) case where
we do not query key manager.

Once more flows are created/destroyed (or the flow cache is overloaded and
often cleans out other entries) this function (and the state lock)
start to show up in perf.

Florian Westphal (6):
      xfrm: state: use hlist_for_each_entry_rcu helper
      xfrm: state: use atomic_inc_not_zero to increment refcount
      xfrm: state: delay freeing until rcu grace period has elapsed
      xfrm: state: add sequence count to detect hash resizes
      xfrm: state: use rcu_deref and assign_pointer helpers
      xfrm: state: don't use lock anymore unless acquire operation is needed

 include/net/netns/xfrm.h |    6 +-
 net/xfrm/xfrm_state.c    |  103 +++++++++++++++++++++++++++++++----------------
 2 files changed, 72 insertions(+), 37 deletions(-)

NB: I have a similar patch series for the policy rwlock, I will send
it once/if this series is applied.
