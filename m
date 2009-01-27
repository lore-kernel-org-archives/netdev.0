From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3] tcp: splice as many packets as possible at once
Date: Tue, 27 Jan 2009 22:48:05 +1100
Message-ID: <20090127114805.GA30982@gondor.apana.org.au>
References: <20090125.212203.15909648.davem@davemloft.net> <20090127071130.GA29125@gondor.apana.org.au> <20090127075418.GB4197@ff.dom.local> <20090127100958.GA30239@gondor.apana.org.au> <20090127103511.GE4197@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52839 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752703AbZA0Lsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 06:48:41 -0500
Content-Disposition: inline
In-Reply-To: <20090127103511.GE4197@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 10:35:11AM +0000, Jarek Poplawski wrote:
>
> > > Yes, but ip_append_data() (and skb_append_datato_frags() for
> > > NETIF_F_UFO only, so currently not a problem), uses this differently,
> > > and these pages in sk->sk_sndmsg_page could leak or be used after
> > > kfree. (I didn't track locking in these other places).
> > 
> > It'll be freed when the socket is freed so that should be fine.
> 
> I don't think so: these places can overwrite sk->sk_sndmsg_page left
> after tcp_sendmsg(), or skb_splice_bits() now, with NULL or a new
> pointer without put_page() (they only reference copied chunks and
> expect auto freeing). On the other hand, if tcp_sendmsg() reads after
> them it could use a pointer after the page is freed, I guess.

I wasn't referring to the first part of your sentence.  That can't
happen because they're only used for UDP sockets, this is a TCP
socket.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
