From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc list locking
Date: Fri, 22 Aug 2008 03:28:44 -0700 (PDT)
Message-ID: <20080822.032844.180232337.davem@davemloft.net>
References: <20080821222446.GF14521@gondor.apana.org.au>
	<20080822092729.GA14729@ff.dom.local>
	<20080822101526.GC14345@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53474
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755136AbYHVK2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 06:28:45 -0400
In-Reply-To: <20080822101526.GC14345@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 Aug 2008 20:15:26 +1000

> On Fri, Aug 22, 2008 at 09:27:30AM +0000, Jarek Poplawski wrote:
> > 
> > pkt_sched: Fix qdisc list locking
> > 
> > Since some qdiscs call qdisc_tree_decrease_qlen() (so qdisc_lookup())
> > without rtnl_lock(), adding and deleting from a qdisc list needs
> > additional locking. This patch adds global spinlock qdisc_list_lock
> > and wrapper functions for modifying the list. It is considered as a
> > temporary solution until hfsc_dequeue(), netem_dequeue() and
> > tbf_dequeue() (or qdisc_tree_decrease_qlen()) are redone.
> > 
> > With feedback from Herbert Xu and David S. Miller.
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

I'll add you ACK, thanks Herbert.

> Good catch! I'm not sure whether this would actually break but
> it certainly makes me feel a lot better :)

Thankfully list_del() on an empty list works or we'd have tons of
reports :)
