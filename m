From: Willy Tarreau <w@1wt.eu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Wed, 7 Jan 2009 14:15:39 +0100
Message-ID: <20090107131539.GF6307@1wt.eu>
References: <20090107115921.GA25323@gondor.apana.org.au> <20090107121530.GA30164@ioremap.net> <20090107122238.GB25673@gondor.apana.org.au> <20090107123741.GA31255@ioremap.net> <20090107124246.GA26034@gondor.apana.org.au> <20090107124629.GA31732@ioremap.net> <20090107125535.GC6307@1wt.eu> <20090107125734.GA26331@gondor.apana.org.au> <20090107130259.GB32336@ioremap.net> <20090107131057.GD9677@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1232 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079AbZAGNPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 08:15:51 -0500
Content-Disposition: inline
In-Reply-To: <20090107131057.GD9677@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 01:10:57PM +0000, Jarek Poplawski wrote:
> On Wed, Jan 07, 2009 at 04:02:59PM +0300, Evgeniy Polyakov wrote:
> ...
> > If I understood correctly Jarek's patch, he wants to allocate a page and
> > copy linear content of the skb there, so this will end up being the same
> > case as with splicing from the file. And while generally this may be a
> > good idea, but with usual 1.5k mtu this will copy every skb, which is
> > rather bad idea. Will have to think :)
> > 
> 
> As I mentioned earlier, I (poorly) tried to realize Changli's idea
> only, and it's more to verify the reason still (after it failed with
> SG method...).

Jarek, since it now works when disabling both SG and GSO, we know that the
bug is triggered when passing through do_tcp_sendpage(). Thus, I will not
try your patch #3 yet, but rather wait for fix candidates to try.

Thanks!
Willy

