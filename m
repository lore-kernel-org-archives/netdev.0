From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH V2 0/3] qdisc bulk dequeuing and utilizing
	delayed tailptr updates
Date: Thu, 04 Sep 2014 14:54:20 +0200
Message-ID: <20140904125247.4108.8132.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47428 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411AbaIDMye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 08:54:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wanted people to review this work early... so this is the current
state, even added my debug patch, if people want to "see" it work.

I'm currently testing with different combination of netperf, and
different on/off adjustments of {gso,gro,tso} as this influences the
code path / skb list generation vs. real GSOs.

Open questions:

- For now set bulk limit to 6 packets (counting including the head),
  this need some user adjustable param.  I'm open to suggestions?
  Perhaps we should start with 2 packets, or disable it as default?

- We are not doing proper accounting for weight_p/quota in
  __qdisc_run().  Should we reduce change this.  Open to suggestions.

---

Jesper Dangaard Brouer (2):
      qdisc: debug statements while testing prev-patch
      qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE

Tom Herbert (1):
      net: Functions to report space available in device TX queues


 include/linux/netdevice.h |   28 ++++++++++++-
 net/sched/sch_generic.c   |   95 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 118 insertions(+), 5 deletions(-)
