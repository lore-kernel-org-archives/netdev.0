From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Sun, 10 Aug 2008 00:32:40 +0200
Message-ID: <20080809223240.GA3085@ami.dom.local>
References: <EA929A9653AAE14F841771FB1DE5A1365F1FBE8B45@rrsmsx501.amr.corp.intel.com> <20080802.192639.02765648.davem@davemloft.net> <EA929A9653AAE14F841771FB1DE5A1365F1FDE30F1@rrsmsx501.amr.corp.intel.com> <20080809.002956.58270696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:41324 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbYHIWbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 18:31:16 -0400
Received: by fg-out-1718.google.com with SMTP id 19so789993fgg.17
        for <netdev@vger.kernel.org>; Sat, 09 Aug 2008 15:31:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080809.002956.58270696.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 09, 2008 at 12:29:56AM -0700, David Miller wrote:
> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> Date: Fri, 8 Aug 2008 13:38:32 -0600
> 
> > I ran into similar panic again. This time on driver reload while
> > passing traffic.
> 
> Thanks.  I think I know what's going on here but coming up
> with a fix will take a little bit longer than usual.

I guess you're thinking about something bigger, but here is a little,
maybe unrelated idea, which I think looks reasonable: after changing
the qdiscs, we should care more about pending activities on the "real"
one instead of the noop.

Jarek P.
---

 net/sched/sch_generic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7cf83b3..7bce88d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -658,7 +658,7 @@ static bool some_qdisc_is_running(struct net_device *dev, int lock)
 		int val;
 
 		dev_queue = netdev_get_tx_queue(dev, i);
-		q = dev_queue->qdisc;
+		q = dev_queue->qdisc_sleeping;
 		root_lock = qdisc_lock(q);
 
 		if (lock)
