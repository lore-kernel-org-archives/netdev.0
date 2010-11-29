From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net-next: Fix __inet_inherit_port() to correctly
	increment bsockets and num_owners
Date: Mon, 29 Nov 2010 13:12:01 +0000
Message-ID: <20101129131201.GB9286@ff.dom.local>
References: <20101128230041.GA16269@ioremap.net> <20101129123909.GA9286@ff.dom.local> <20101129125102.GA17736@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nagendra Tomar <tomer_iisc@yahoo.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60991 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822Ab0K2NMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 08:12:03 -0500
Received: by fxm8 with SMTP id 8so61591fxm.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 05:12:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101129125102.GA17736@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 29, 2010 at 03:51:02PM +0300, Evgeniy Polyakov wrote:
> On Mon, Nov 29, 2010 at 12:39:09PM +0000, Jarek Poplawski (jarkao2@gmail.com) wrote:
> > >> inet sockets corresponding to passive connections are added to the bind hash
> > >> using ___inet_inherit_port(). These sockets are later removed from the bind 
> > >> hash using __inet_put_port(). These two functions are not exactly symmetrical. 
> > >> __inet_put_port() decrements hashinfo->bsockets and tb->num_owners, whereas 
> > >> ___inet_inherit_port() does not increment them. This results in both of these 
> > >> going to -ve values.
> > >>
> > >> This patch fixes this by calling inet_bind_hash() from ___inet_inherit_port(),
> > >> which does the right thing.
> > >>
> > >> 'bsockets' and 'num_owners' were introduced by commit a9d8f9110d7e953c 
> > >> (inet: Allowing more than 64k connections and heavily optimize bind(0))
> > > 
> > > Yup, things changed from that simple patch a lot.
> > > Thanks for fixing it up.
> > > Ack.
> > 
> > Probably I miss something, but since bsockets is increased by each
> > passive connection now, it seems it will trigger "hash table is full"
> > too early?
> 
> Why would it? bsockets and num_owners are supposed to be increased for each
> new socket added into the table, and are used as a hint to find a bucket with
> the smallest number of sockets in it.
> 
> Hash table insertion did not change, only bucket selection algorithm got
> a hint.

Evgeniy & Eric,

But it's compared to the numer of available port numbers in
inet_csk_get_port():

     "if (atomic_read(&hashinfo->bsockets) > (high - low) + 1)"

Can't you have bsockets higher than this with only one port used?

Jarek P.
