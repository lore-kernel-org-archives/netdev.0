From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RFC] make qdisc_restart more readable
Date: Fri, 11 May 2007 11:13:06 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902D424F4@orsmsx414.amr.corp.intel.com>
References: <1178906671.4126.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4986 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761192AbXEKSNJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 14:13:09 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1178906671.4126.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Fri, 2007-11-05 at 08:56 -0700, Waskiewicz Jr, Peter P wrote:
> 
> > In qdisc_restart(), you removed any check for if
> > (!netif_queue_stopped(dev)) before calling 
> dev_hard_start_xmit().  If 
> > the underlying queue is stopped and you send the skb, 
> you'll generate 
> > a requeue.  Is there a reason it was removed?
> > 
> 
> No - its a bug ;->
> Thanks for staring at this Peter. I will fix it.
> 
> cheers,
> jamal

After thinking about this a bit more: even if the queue is stopped,
you'd end up requeueing anyways.  Plus, you'd need to re-acquire
dev->queue_lock (which is what happens today).  I think the best way
overall would be to check the queue state before you physically dequeue
(whether it's in qdisc_restart() or in the qdisc's ->dequeue()).  That
way you still hold dev->queue_lock in case the queue is stopped, and
haven't yet pulled an skb causing a requeue event.

Just $0.02 on Friday.

Thx,

-PJ Waskiewicz
