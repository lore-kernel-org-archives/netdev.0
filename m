From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 20:52:18 +1100
Message-ID: <20090107095218.GA24264@gondor.apana.org.au>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106183704.GC32491@kernel.dk> <20090107044232.GA22218@gondor.apana.org.au> <20090107063859.GA30749@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34789 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751121AbZAGJwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 04:52:39 -0500
Content-Disposition: inline
In-Reply-To: <20090107063859.GA30749@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 07:38:59AM +0100, Willy Tarreau wrote:
>
> > Unfortunately, once the pipe is fed into sendpage we only use
> > page reference counting to pin down the memory.  So as soon as
> > sendpage returns we drop the ref count on the skb, thus freeing
> > the memory in skb->head, which is yet to be transmitted.
> 
> So this means that anything relying on sendpage() is at risk ? What

No the bug is in the splice code.  sendfile() and other sendpage
users are not affected.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
