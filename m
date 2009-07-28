From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Mon, 27 Jul 2009 21:21:07 -0700 (PDT)
Message-ID: <20090727.212107.161491585.davem@davemloft.net>
References: <20090725032436.GA30741@gondor.apana.org.au>
	<20090727.192844.163233275.davem@davemloft.net>
	<20090728024813.GA23992@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51347
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750971AbZG1EVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 00:21:00 -0400
In-Reply-To: <20090728024813.GA23992@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 28 Jul 2009 10:48:13 +0800

> On Mon, Jul 27, 2009 at 07:28:44PM -0700, David Miller wrote:
>>
>> There is a locking benefit even for non-default qdiscs.
>> 
>> Instead of two choke points (qdisc lock and queue lock) there
>> is now only one (qdisc lock) and consdiering the cost of
>> things like setting up IOMMU mappings and hitting chip
>> registers the qdisc lock is the shortest held of the two.
> 
> But only one CPU can process a given qdisc at one time so I don't
> see why there is a second choke point if you use a single queue
> with a non-default qdisc.

Good point, but this only suggests that we might want to undo that
queue runner exclusivity state bit for this case especially when we
know that we are feeding a multiqueue device.
