From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/3] qdisc bulk dequeuing and utilizing delayed
	tailptr updates
Date: Tue, 02 Sep 2014 16:35:19 +0200
Message-ID: <20140902143254.1918.8419.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754061AbaIBOfd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 10:35:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
from the qdisc layer, to implement dequeue bulking.

Open questions:

- For now set bulk limit to 8 packets, don't want to stress the driver
  avail ring_buffer space.

- We are not doing proper accounting for weight_p/quota in __qdisc_run(). Do we care?

- Is the (!skb->next) check in dequeue necessary?

- Do we need some checks in dev_requeue_skb() as we could be requeuing a SKB list?

 - Should we rename dequeue_skb() to dequeue_skb_list() ?


Based on top of:
 commit 364a9e93243d ("sock: deduplicate errqueue dequeue")

---

Jesper Dangaard Brouer (3):
      qdisc: sysctl to adjust bulk dequeue limit
      qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE
      qdisc: adjustments for API allowing skb list xmits


 include/net/sch_generic.h  |    2 ++
 net/core/sysctl_net_core.c |    9 +++++++++
 net/sched/sch_generic.c    |   33 ++++++++++++++++++++++++++++-----
 3 files changed, 39 insertions(+), 5 deletions(-)

-- 
