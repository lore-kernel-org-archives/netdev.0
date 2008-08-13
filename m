From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 02:30:56 -0700 (PDT)
Message-ID: <20080813.023056.198536297.davem@davemloft.net>
References: <E1KT803-00086Y-00@gondolin.me.apana.org.au>
	<20080812.221103.91087925.davem@davemloft.net>
	<20080813053118.GA31785@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44546
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751767AbYHMJaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 05:30:55 -0400
In-Reply-To: <20080813053118.GA31785@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 13 Aug 2008 15:31:18 +1000

> On Tue, Aug 12, 2008 at 10:11:03PM -0700, David Miller wrote:
> > Hmmm... maybe we have to sample __QDISC_STATE_SCHED too.
> 
> You need this too for the ones which aren't running but sitting
> on output_queue.  Either you'll have to forcibly remove them as
> I outlined earlier, or just wait for them to expire naturally.
> 
> The latter would seem more suitable since we're waiting anyway.

This is what I do in the patch I just posted.
