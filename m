From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: restore qdisc quota fairness limits after
 bulk dequeue
Date: Thu, 09 Oct 2014 19:12:48 -0400 (EDT)
Message-ID: <20141009.191248.516797236807606254.davem@davemloft.net>
References: <20141009101640.26713.80729.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, dborkman@redhat.com,
	dave.taht@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbaJIXMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 19:12:50 -0400
In-Reply-To: <20141009101640.26713.80729.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 09 Oct 2014 12:18:10 +0200

> Restore the quota fairness between qdisc's, that we broke with commit
> 5772e9a346 ("qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE").
> 
> Before that commit, the quota in __qdisc_run() were in packets as
> dequeue_skb() would only dequeue a single packet, that assumption
> broke with bulk dequeue.
> 
> We choose not to account for the number of packets inside the TSO/GSO
> packets (accessable via "skb_gso_segs").  As the previous fairness
> also had this "defect". Thus, GSO/TSO packets counts as a single
> packet.
> 
> Further more, we choose to slack on accuracy, by allowing a bulk
> dequeue try_bulk_dequeue_skb() to exceed the "packets" limit, only
> limited by the BQL bytelimit.  This is done because BQL prefers to get
> its full budget for appropriate feedback from TX completion.
> 
> In future, we might consider reworking this further and, if it allows,
> switch to a time-based model, as suggested by Eric. Right now, we only
> restore old semantics.
> 
> Joint work with Eric, Hannes, Daniel and Jesper.  Hannes wrote the
> first patch in cooperation with Daniel and Jesper.  Eric rewrote the
> patch.
> 
> Fixes: 5772e9a346 ("qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Looks fantastic, thanks everyone.
