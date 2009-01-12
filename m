From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Mon, 12 Jan 2009 23:56:07 +1100
Message-ID: <20090112125607.GA6370@gondor.apana.org.au>
References: <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu> <20090107123153.GA9597@ff.dom.local> <20090107123504.GN32491@kernel.dk> <20090107124946.GA9677@ff.dom.local> <20090107125217.GA26235@gondor.apana.org.au> <20090112120257.GA5697@gondor.apana.org.au> <20090112124545.GA10893@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	Changli Gao <xiaosuo@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40743 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752127AbZALM4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 07:56:25 -0500
Content-Disposition: inline
In-Reply-To: <20090112124545.GA10893@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 03:45:46PM +0300, Evgeniy Polyakov wrote:
>
> As a long-term solution this sounds as the best case, but introduces
> quite heavy overhead for the allocators. Right now we allocate
> 1500+shared_info rounded up to the nearest power of the two (2k), but
> then we will either need to have own network allocator (I have one :) or
> allocate PAGE_SIZE+shared_info rounded up to the pwoer of the two (i.e.
> 8k), which is unfeasible.

No that's not what I was suggesting.  The page split model allocates
an skb with a very small head that accomodates only the headers.
All payload is stored in the frags structure.

For 1500-byte packets, we can manage the payload area efficiently
by dividing each allocated page into 2K chunks.  The page will
then be automatically freed once all the 2K chunks on it have been
freed through the page ref count mechanism.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
