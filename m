From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 13:02:35 -0700 (PDT)
Message-ID: <20090728.130235.208796779.davem@davemloft.net>
References: <20090728080354.GA25953@gondor.apana.org.au>
	<20090728083713.GB5424@ff.dom.local>
	<20090728084451.GA26299@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, krkumar2@in.ibm.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51459
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750695AbZG1UC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 16:02:28 -0400
In-Reply-To: <20090728084451.GA26299@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 28 Jul 2009 16:44:51 +0800

> Well the fact that as it stands the only true multiqueue qdisc
> is the default is a mere coincidence.  There is no fundamental
> reason why non-default qdiscs cannot be made multiqueue aware,
> well, for some of them anyway.
> 
> For example, sfq can naturally be enhanced as a multiqueue qdisc
> just like the default qdisc.
> 
> So I don't think we want to prejudice what a future non-default
> qdisc may support.

The idea is that it cannot be done anywhere we currently
limits, decisions, etc. are all done with "device" scope.

And I think SFQ even falls into that category.

You would need a special SFQ that makes sure to break down traffic
identically to how the TX queue selection divides traffic, and even
then I'm not even so sure how implementable that is.
