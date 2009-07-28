From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 10:48:13 +0800
Message-ID: <20090728024813.GA23992@gondor.apana.org.au>
References: <20090724083749.GA23521@gondor.apana.org.au> <OFFA0E0F2C.B17AF73A-ON652575FD.00372349-652575FD.0039CB03@in.ibm.com> <20090725032436.GA30741@gondor.apana.org.au> <20090727.192844.163233275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34273 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752544AbZG1CsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 22:48:24 -0400
Content-Disposition: inline
In-Reply-To: <20090727.192844.163233275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 27, 2009 at 07:28:44PM -0700, David Miller wrote:
>
> There is a locking benefit even for non-default qdiscs.
> 
> Instead of two choke points (qdisc lock and queue lock) there
> is now only one (qdisc lock) and consdiering the cost of
> things like setting up IOMMU mappings and hitting chip
> registers the qdisc lock is the shortest held of the two.

But only one CPU can process a given qdisc at one time so I don't
see why there is a second choke point if you use a single queue
with a non-default qdisc.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
