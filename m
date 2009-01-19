From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Mon, 19 Jan 2009 07:32:35 +0000
Message-ID: <20090119073235.GA4600@ff.dom.local>
References: <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu> <20090107123153.GA9597@ff.dom.local> <20090107123504.GN32491@kernel.dk> <20090107124946.GA9677@ff.dom.local> <20090107125217.GA26235@gondor.apana.org.au> <20090112120257.GA5697@gondor.apana.org.au> <20090112131517.GD5901@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	Changli Gao <xiaosuo@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:23764 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbZASHcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 02:32:43 -0500
Content-Disposition: inline
In-Reply-To: <20090112131517.GD5901@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 01:15:17PM +0000, Jarek Poplawski wrote:
...
> I've wondered if something like this could work as a temporary hack?
...
> @@ -776,7 +777,8 @@ ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
>  	struct sock *sk = sock->sk;
>  
>  	if (!(sk->sk_route_caps & NETIF_F_SG) ||
> -	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
> +	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM) ||
> +	    PageSlab(page))
>  		return sock_no_sendpage(sock, page, offset, size, flags);

Just for the record: this wouldn't work yet:-( It should be probably
something like "PageCompound(compound_head(page))" test instead.

Jarek P.
