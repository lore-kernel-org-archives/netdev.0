From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH v2 0/3] net: sched: allow switching qdisc to noqueue intuitively
Date: Sat, 22 Aug 2015 02:20:53 +0200
Message-ID: <1440202856-1645-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:53210 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752062AbbHVAU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 20:20:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series improves the integration of the noqueue qdisc to become the
fallback queueing if no other is attached to an interface. Before it was rather
an add-on, a simpler alternative to a FIFO if no congestion is expected or
possible. It has become the default qdisc for virtual interfaces, and could be
attached by this mechanism only (through removing the root qdisc after having
set tx_queue_len to zero for interfaces not defaulting to noqueue otherwise).

This series does not change the default qdisc chosen for new interfaces, but
upon removal of the root qdisc from an interface, the kernel won't fall back to
the default but to noqueue instead.

Changes since v1:
- Leave qdisc_create_dflt() alone as it is used in sch_htb.c as well. Instead
  allocate the handle in attach_default_qdiscs() and
  attach_one_default_qdisc().

Phil Sutter (3):
  net: sched: make noqueue_qdisc non-static
  net: sched: allocate a handle to default qdiscs
  net: sched: fall back to noqueue when removing root qdisc

 include/net/sch_generic.h |  2 ++
 net/sched/sch_api.c       |  5 +++--
 net/sched/sch_generic.c   | 18 ++++++++++++++----
 3 files changed, 19 insertions(+), 6 deletions(-)

-- 
2.1.2
