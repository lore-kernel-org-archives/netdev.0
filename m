From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 04:36:52 +0200
Message-ID: <20080731023652.GA23814@xi.wantstofly.org>
References: <20080731004123.GB22826@xi.wantstofly.org> <E1KONuu-00017h-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, akarkare@marvell.com,
	nico@cam.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:36140 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755812AbYGaCgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 22:36:54 -0400
Content-Disposition: inline
In-Reply-To: <E1KONuu-00017h-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 10:29:24AM +0800, Herbert Xu wrote:

> > Index: linux-2.6.27-rc1/net/ipv4/tcp_output.c
> > ===================================================================
> > --- linux-2.6.27-rc1.orig/net/ipv4/tcp_output.c
> > +++ linux-2.6.27-rc1/net/ipv4/tcp_output.c
> > @@ -1544,7 +1544,7 @@ static int tcp_write_xmit(struct sock *s
> >                        break;
> > 
> >                if (tso_segs == 1) {
> > -                       if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
> > +                       if (unlikely(!tcp_nagle_test(tp, skb, 5 * mss_now,
> >                                                     (tcp_skb_is_last(sk, skb) ?
> >                                                      nonagle : TCP_NAGLE_PUSH))))
> >                                break;
> 
> What's the size of your application's write calls?

The maximum that splice will allow -- PIPE_BUFFERS * PAGE_SIZE.

I.e. the writes should be large enough.
