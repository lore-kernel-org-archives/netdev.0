From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 06:43:19 +0000
Message-ID: <20090728064319.GA5424@ff.dom.local>
References: <20090725032436.GA30741@gondor.apana.org.au> <20090727.192844.163233275.davem@davemloft.net> <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f216.google.com ([209.85.220.216]:42876 "EHLO
	mail-fx0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104AbZG1GnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 02:43:25 -0400
Received: by fxm12 with SMTP id 12so170000fxm.37
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2009 23:43:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090727.212107.161491585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 27, 2009 at 09:21:07PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 28 Jul 2009 10:48:13 +0800
> 
> > On Mon, Jul 27, 2009 at 07:28:44PM -0700, David Miller wrote:
> >>
> >> There is a locking benefit even for non-default qdiscs.
> >> 
> >> Instead of two choke points (qdisc lock and queue lock) there
> >> is now only one (qdisc lock) and consdiering the cost of
> >> things like setting up IOMMU mappings and hitting chip
> >> registers the qdisc lock is the shortest held of the two.
> > 
> > But only one CPU can process a given qdisc at one time so I don't
> > see why there is a second choke point if you use a single queue
> > with a non-default qdisc.
> 
> Good point, but this only suggests that we might want to undo that
> queue runner exclusivity state bit for this case especially when we
> know that we are feeding a multiqueue device.

I guess the main sacrifice of Herbert's idea is sch_multiq, and we
could probably consider some compromise like doing qdisc_run (with
qdisc_restart) a callback or only adding a "if default qdisc" check,
depending on costs/gains.

Jarek P.
