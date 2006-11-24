From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 04/06]: Fix endless loops (part 2): "simple" qdiscs
Date: Fri, 24 Nov 2006 14:07:08 +0100
Message-ID: <4566EE7C.4090801@trash.net>
References: <20061124123350.GA1599@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34559 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1757732AbWKXNHL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 08:07:11 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061124123350.GA1599@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
>>diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
>>index 908b10d..ba82dfa 100644
>>--- a/net/sched/sch_cbq.c
>>+++ b/net/sched/sch_cbq.c
>>@@ -1687,7 +1687,7 @@ #endif
>> 		sch_tree_lock(sch);
>> 		*old = cl->q;
>> 		cl->q = new;
>>-		sch->q.qlen -= (*old)->q.qlen;
>>+		qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
>> 		qdisc_reset(*old);
>> 		sch_tree_unlock(sch);
>>
> 
> 
> Hello,
> 
> Probably it is as usual something with my eyes but
> it seems cbq needs in cbq_delete or cbq_destroy_class
> some treatment (about qdisc_destroy) similar to htb.

No, you're right about this one, CBQ needs a few further fixes:

- deactivating of active classes when grafting

- purging of queue/q.qlen adjustment when deleting an active class

- deactivating of active classes when q.qlen drops to zero in ->drop()

- purging of queue and deactivating of active leaf classes
  when attaching a new child (presuming CBQ can only carry
  packets in leaf classes, I'm not sure about this)

and something HTB should do is to turn intermediate classes
into leaves again when their last child is deleted.

Are you interested in fixing this? :)
