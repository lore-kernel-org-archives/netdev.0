From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 08:37:13 +0000
Message-ID: <20090728083713.GB5424@ff.dom.local>
References: <20090725032436.GA30741@gondor.apana.org.au> <20090727.192844.163233275.davem@davemloft.net> <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728064319.GA5424@ff.dom.local> <20090728080354.GA25953@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f221.google.com ([209.85.218.221]:38703 "EHLO
	mail-bw0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbZG1Inr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:43:47 -0400
Received: by bwz21 with SMTP id 21so743710bwz.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 01:43:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090728080354.GA25953@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 04:03:54PM +0800, Herbert Xu wrote:
> On Tue, Jul 28, 2009 at 06:43:19AM +0000, Jarek Poplawski wrote:
> >
> > I guess the main sacrifice of Herbert's idea is sch_multiq, and we
> > could probably consider some compromise like doing qdisc_run (with
> > qdisc_restart) a callback or only adding a "if default qdisc" check,
> > depending on costs/gains.
> 
> Indeed, getting rid of multiple queues for all non-default qdiscs
> is overly drastic.  Here's a different plan.  We add the proposed
> check only for the default qdisc (we still need to fix act_skbedit)
> though) while all non-default qdiscs continue to behave as they
> currently do.
> 
> This can be done by setting dev_queue for non-default qdiscs to
> NULL and checking that before we do qdisc_run:
> 
> 	if (!dev_queue || !queue_stopped(dev_queue))
> 		qdisc_run
> 
> This makes sense as non-default qdiscs do not map bijectively onto
> dev queues so they shouldn't really have a pointer to a dev queue.
> 
> Of course we'll need to fix those places that use dev_queue for
> other purposes such as getting back to the device.  If that is
> too much work we could just add a new field that is identical
> to dev_queue for the default qdisc but is NULL for non-default
> qdiscs.

Hmm.. would something IMHO_more_readable/less_fixing like:
(qdisc->flags & TCQ_F_DEFAULT) be too much? (Btw, IIRC there was an
idea long time ago to treat all queues equally.)

Cheers,
Jarek P.
