From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Thu, 11 Sep 2008 03:39:56 -0700 (PDT)
Message-ID: <20080911.033956.233317469.davem@davemloft.net>
References: <20080821064941.GA2764@ff.dom.local>
	<20080821071634.GA1269@gondor.apana.org.au>
	<20080821.005250.117238212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43330
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752007AbYIKKkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 06:40:02 -0400
In-Reply-To: <20080821.005250.117238212.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 21 Aug 2008 00:52:50 -0700 (PDT)

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 21 Aug 2008 17:16:34 +1000
> 
> > Actually, why do we even keep a netdev_queue pointer in a qdisc?
> > A given qdisc can be used by multiple queues (which is why the
> > lock was moved into the qdisc in the first place).
> > 
> > How about keeping a pointer directly to the root qdisc plus a
> > pointer to the netdev (which seems to be the only other use for
> > qdisc->dev_queue)? That way there won't be any confusion as to
> > whether we want the sleeping or non-sleeping qdisc.
> 
> Not a bad idea at all.
> 
> The reason it's there is a left-over from earlier designs of my
> multiqueue stuff, I thought we'd always multiplex the qdiscs to be
> per-queue.  But once Patrick showed me we couldn't do that, we now
> have shared qdiscs.

I got to looking into this and we do need the qdisc->dev_queue member,
see qdisc_run().  So it's not like we can get rid of it if we replace
it with ->netdevdev and add a ->root_qdisc backpointer as well.

