From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 12:49:36 +0000
Message-ID: <20080821124936.GE4079@ff.dom.local>
References: <20080821120112.GA7705@gondor.apana.org.au> <20080821121920.GD4079@ff.dom.local> <20080821122245.GA8533@gondor.apana.org.au> <20080821.052754.104318066.davem@davemloft.net> <20080821123538.GA8703@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:57086 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbYHUMtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:49:43 -0400
Received: by nf-out-0910.google.com with SMTP id d3so458788nfc.21
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 05:49:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821123538.GA8703@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 10:35:38PM +1000, Herbert Xu wrote:
> On Thu, Aug 21, 2008 at 05:27:54AM -0700, David Miller wrote:
> > 
> > This looks even worse, actually.
> > 
> > If we just unlinked this thing, we don't want anyone finding
> > it, even before we grab this lock, to adjust queue counts.
> 
> You're right, this doesn't work at all.  In fact it's been broken
> even before we removed the root lock.  The problem is that we used
> to have one big linked list for each device.  That was protected
> by the device qdisc lock.  Now we have one list for each txq and
> qdisc_lookup walks every single txq.  This means that no single
> qdisc root lock can protect this anymore.
> 

I don't think there could be such a problem, since nobody should look
for such a destroyed qdisc: they look for their ancestors only.
Anyway, I can't do this patch before evening, so I wait for
suggestions or you could simply do it as you wish, no problem.

Cheers,
Jarek P.
