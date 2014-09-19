From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH V3 0/2] qdisc bulk dequeuing and utilizing
	delayed tailptr updates
Date: Fri, 19 Sep 2014 22:49:08 +0200
Message-ID: <20140919204706.3231.59125.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757964AbaISUtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 16:49:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
from the qdisc layer, to implement dequeue bulking.

RFC V3: Keeping the ball rolling.

This patchset should now use BQL correctly.  I've done lots of testing
for Head-of-Line blocking issues that can occur due to requeue of a
SKB bulk list.  I've not been able to provoke any HoL blocking
situation, simply because BQL is doing such a good job, thus I'm
unable to "overshoot" HW/BQL limits with more than a single packet.

This patch chooses a very conservative approach, as by default only
allowing dequeue of one extra packet, besides the normal dequeue.

Open questions:

- How do we expose tuning to userspace?
  Patch adds /proc/sys/net/core/qdisc_bulk_dequeue_limit but I don't like it...
  Per device tunable?

- Can/should we limit dequeue bulking to devices supporting BQL?


Based on top of net-next:
 commit cb93471acc (tcp: do not fake tcp headers in tcp_send_rcvq())


---

Jesper Dangaard Brouer (1):
      qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE

Tom Herbert (1):
      net: Functions to report space available in device TX queues


 include/linux/netdevice.h  |   28 ++++++++++++++++--
 include/net/sch_generic.h  |    2 +
 net/core/sysctl_net_core.c |    9 ++++++
 net/sched/sch_generic.c    |   70 ++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 104 insertions(+), 5 deletions(-)

-- 
