From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] net-next: Fix __inet_inherit_port() to correctly
 increment bsockets and num_owners
Date: Mon, 29 Nov 2010 15:51:02 +0300
Message-ID: <20101129125102.GA17736@ioremap.net>
References: <20101128230041.GA16269@ioremap.net>
 <20101129123909.GA9286@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nagendra Tomar <tomer_iisc@yahoo.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:60859 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752204Ab0K2MvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 07:51:04 -0500
Content-Disposition: inline
In-Reply-To: <20101129123909.GA9286@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 29, 2010 at 12:39:09PM +0000, Jarek Poplawski (jarkao2@gmail.com) wrote:
> >> inet sockets corresponding to passive connections are added to the bind hash
> >> using ___inet_inherit_port(). These sockets are later removed from the bind 
> >> hash using __inet_put_port(). These two functions are not exactly symmetrical. 
> >> __inet_put_port() decrements hashinfo->bsockets and tb->num_owners, whereas 
> >> ___inet_inherit_port() does not increment them. This results in both of these 
> >> going to -ve values.
> >>
> >> This patch fixes this by calling inet_bind_hash() from ___inet_inherit_port(),
> >> which does the right thing.
> >>
> >> 'bsockets' and 'num_owners' were introduced by commit a9d8f9110d7e953c 
> >> (inet: Allowing more than 64k connections and heavily optimize bind(0))
> > 
> > Yup, things changed from that simple patch a lot.
> > Thanks for fixing it up.
> > Ack.
> 
> Probably I miss something, but since bsockets is increased by each
> passive connection now, it seems it will trigger "hash table is full"
> too early?

Why would it? bsockets and num_owners are supposed to be increased for each
new socket added into the table, and are used as a hint to find a bucket with
the smallest number of sockets in it.

Hash table insertion did not change, only bucket selection algorithm got
a hint.

-- 
	Evgeniy Polyakov
