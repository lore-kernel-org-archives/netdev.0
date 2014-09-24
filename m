From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/1 V4] qdisc bulk dequeuing and utilizing delayed
 tailptr updates
Date: Wed, 24 Sep 2014 18:10:42 +0200
Message-ID: <20140924160932.9721.56450.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>, toke@toke.dk,
	jhs@mojatatu.com, Dave Taht <dave.taht@gmail.com>
To: netdev@vger.kernel.org, therbert@google.com,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537AbaIXQKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:10:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses DaveM's recent API changes to dev_hard_start_xmit(),
from the qdisc layer, to implement dequeue bulking.

In this V4 iteration we are choosing an conservative approach.

Patch V4:

- Patch rewritten in the Red Hat Neuchatel office jointed work with
  Hannes, Daniel and Florian.
- Conservative approach of only using on BQL enabled drivers
- No user tunable parameter, but limit bulking to 8 packets.
- For now, avoid bulking GSO packets packets.


---

Jesper Dangaard Brouer (1):
      qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE


 include/net/sch_generic.h |   16 +++++++++++++++
 net/sched/sch_generic.c   |   47 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 61 insertions(+), 2 deletions(-)

-- 
