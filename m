From: Willy Tarreau <w@1wt.eu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 10:54:15 +0100
Message-ID: <20090107095415.GB30749@1wt.eu>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106183704.GC32491@kernel.dk> <20090107044232.GA22218@gondor.apana.org.au> <20090107063859.GA30749@1wt.eu> <20090107095218.GA24264@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1190 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbZAGJyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 04:54:31 -0500
Content-Disposition: inline
In-Reply-To: <20090107095218.GA24264@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 08:52:18PM +1100, Herbert Xu wrote:
> On Wed, Jan 07, 2009 at 07:38:59AM +0100, Willy Tarreau wrote:
> >
> > > Unfortunately, once the pipe is fed into sendpage we only use
> > > page reference counting to pin down the memory.  So as soon as
> > > sendpage returns we drop the ref count on the skb, thus freeing
> > > the memory in skb->head, which is yet to be transmitted.
> > 
> > So this means that anything relying on sendpage() is at risk ? What
> 
> No the bug is in the splice code.  sendfile() and other sendpage
> users are not affected.

but sendfile() now uses splice().

Willy

