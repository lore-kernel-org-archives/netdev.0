From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Wed, 24 Sep 2008 07:15:21 +0000
Message-ID: <20080924071521.GA4838@ff.dom.local>
References: <20080920.223538.130375517.davem@davemloft.net> <20080920.225033.261544815.davem@davemloft.net> <20080921063821.GA8677@gondor.apana.org.au> <20080921.000301.198672963.davem@davemloft.net> <20080923062333.GA26595@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, alexander.h.duyck@intel.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:53589 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbYIXHP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 03:15:28 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1990709fgg.17
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 00:15:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080923062333.GA26595@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 02:23:33PM +0800, Herbert Xu wrote:
> On Sun, Sep 21, 2008 at 12:03:01AM -0700, David Miller wrote:
> >
> > This works if you want it at the root, but what if you only wanted to
> > prio at a leaf?  I think that case has value too.
> 
> Good question :)
> 
> I think what we should do is to pass some token that rerepsents
> the TX queue that's being run down into the dequeue function.
> 
> Then each qdisc can decide which child to recursively dequeue
> based on that token (or ignore it for non-prio qdiscs such as
> HTB).

I don't think HTB could be considered as a non-prio qdisc.

> When the token reaches the leaf then we have two cases:
> 1) A prio-like qdisc that has separate queues based on priorities.
> In this case we dequeue the respective queue based on the token.

As matter of fact I can't figure out this idea of a prio at the root
or leaf either. Could you explain in which point do you expect the
gain? If it's about the locks, what kind of synchronization would be
used to assure packets from lower prio queues (or qdiscs?)  aren't
sent to free tx queues, while higher prio wait on stopped ones?

Thanks,
Jarek P.
