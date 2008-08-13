From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 12 Aug 2008 23:16:33 -0700 (PDT)
Message-ID: <20080812.231633.193696650.davem@davemloft.net>
References: <E1KT803-00086Y-00@gondolin.me.apana.org.au>
	<20080812.221103.91087925.davem@davemloft.net>
	<20080813061317.GA4251@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750796AbYHMGQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 02:16:32 -0400
In-Reply-To: <20080813061317.GA4251@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 13 Aug 2008 06:13:17 +0000

> On Tue, Aug 12, 2008 at 10:11:03PM -0700, David Miller wrote:
> > So, just like one of Jarek's patches, we should simply change
> > dev_queue->qdisc into dev_queue->qdisc_sleeping and that should
> > take care of the bulk of the issues.
> > 
> > Shouldn't it?
> 
> If we don't change anything in __netif_schedule() I doubt it's enough.
> And if this old way of waiting for "outstanding qdisc-less" calls was
> really needed we should probably wait for both qdisc and qdisc_sleeping
> then.

I think if we check both RUNNING and SCHED bits, we'll be OK.

> > Hmmm... maybe we have to sample __QDISC_STATE_SCHED too.
> 
> We could probably even think of using this flag napi_disable() way.

Here (in dev_deactivate), ->qdisc is going to now be &noop_qdisc or
similar.  Asynchronous contexts can run into that thing as much as
they want :-)
