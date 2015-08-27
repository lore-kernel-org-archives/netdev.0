From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 0/4] fixup IFF_NO_QUEUE conversion
Date: Thu, 27 Aug 2015 21:21:35 +0200
Message-ID: <1440703299-21243-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com,
	geert@linux-m68k.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:47175 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234AbbH0TVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2015 15:21:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series serves two purposes:

On one hand it fixes a quite embarrassing bug around the warning I added for
drivers still setting tx_queue_len = 0 to achieve noqueue operation. It turned
out to be quite useless as due to using alloc_netdev(), many in-kernel drivers
fell into the trap by accident, as well. Instead this place serves pretty well
as a sanitizing point to set IFF_NO_QUEUE for drivers not initializing
tx_queue_len, which in turn allows to drop all special treatment of the latter
being zero since that can not happen anymore without IFF_NO_QUEUE being set.

On the other hand, it provides a better solution for Eric Dumazet's concern
regarding how to assign noqueue to an interface which does not default to it
already. In order to make this possible, noqueue is being registered so users
can 'tc qd add dev eth0 root noqueue'. In addition, it resolves the ugly
situation of 'tc qd show' not showing noqueue. Finally, the former changes
allow for some code cleanup.

Phil Sutter (4):
  net: fix IFF_NO_QUEUE for drivers using alloc_netdev
  net: sched: ignore tx_queue_len when assigning default qdisc
  net: sched: register noqueue qdisc
  net: sched: simplify attach_one_default_qdisc()

 include/net/sch_generic.h |  1 +
 net/core/dev.c            |  2 +-
 net/sched/sch_api.c       |  1 +
 net/sched/sch_generic.c   | 54 ++++++++++++++++++++---------------------------
 4 files changed, 26 insertions(+), 32 deletions(-)

-- 
2.1.2
