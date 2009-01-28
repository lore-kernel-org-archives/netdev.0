From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v3] tcp: splice as many packets as possible at once
Date: Wed, 28 Jan 2009 08:10:54 +0000
Message-ID: <20090128081054.GA4190@ff.dom.local>
References: <20090127114805.GA30982@gondor.apana.org.au> <20090127121642.GA5866@ff.dom.local> <20090127123111.GB5866@ff.dom.local> <20090127.090651.237239521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:38508 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbZA1ILB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 03:11:01 -0500
Content-Disposition: inline
In-Reply-To: <20090127.090651.237239521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 09:06:51AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Tue, 27 Jan 2009 12:31:11 +0000
> 
> > On Tue, Jan 27, 2009 at 12:16:42PM +0000, Jarek Poplawski wrote:
> > > On Tue, Jan 27, 2009 at 10:48:05PM +1100, Herbert Xu wrote:
> > > > On Tue, Jan 27, 2009 at 10:35:11AM +0000, Jarek Poplawski wrote:
> > > > >
> > > > > > > Yes, but ip_append_data() (and skb_append_datato_frags() for
> > > > > > > NETIF_F_UFO only, so currently not a problem), uses this differently,
> > > > > > > and these pages in sk->sk_sndmsg_page could leak or be used after
> > > > > > > kfree. (I didn't track locking in these other places).
> > > > > > 
> > > > > > It'll be freed when the socket is freed so that should be fine.
> > > > > 
> > > > > I don't think so: these places can overwrite sk->sk_sndmsg_page left
> > > > > after tcp_sendmsg(), or skb_splice_bits() now, with NULL or a new
> > > > > pointer without put_page() (they only reference copied chunks and
> > > > > expect auto freeing). On the other hand, if tcp_sendmsg() reads after
> > > > > them it could use a pointer after the page is freed, I guess.
> > > > 
> > > > I wasn't referring to the first part of your sentence.  That can't
> > > > happen because they're only used for UDP sockets, this is a TCP
> > > > socket.
> > > 
> > > Do you mean this part from ip_append_data() isn't used for TCP?:
> > 
> > Actually, the beginning part of ip_append_data() should be enough too.
> > So I guess I missed your point...
> 
> TCP doesn't use ip_append_data(), period.

Hmm... I see: TCP does use ip_send_reply(), so ip_append_data() too,
but with a special socket.

Thanks for the explanations,
Jarek P.
