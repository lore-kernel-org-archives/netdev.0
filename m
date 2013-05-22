From: Flavio Leitner <fbl@redhat.com>
Subject: Re: RFC limit sk_mem_quantum to 8192
Date: Tue, 21 May 2013 22:58:58 -0300
Message-ID: <20130522015858.GB17240@obelix.rh>
References: <20130522004541.GA17240@obelix.rh>
 <1369184962.3301.264.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25452 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753003Ab3EVB7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 21:59:03 -0400
Content-Disposition: inline
In-Reply-To: <1369184962.3301.264.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 21, 2013 at 06:09:22PM -0700, Eric Dumazet wrote:
> On Tue, 2013-05-21 at 21:45 -0300, Flavio Leitner wrote:
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 5d84de4..d52fa2d 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -954,7 +954,12 @@ static inline struct inode *SOCK_INODE(struct socket *socket)
> >  extern int __sk_mem_schedule(struct sock *sk, int size, int kind);
> >  extern void __sk_mem_reclaim(struct sock *sk);
> >  
> > +#if PAGE_SIZE < 8192
> >  #define SK_MEM_QUANTUM ((int)PAGE_SIZE)
> > +#else
> > +#define SK_MEM_QUANTUM ((int)8192)
> > +#endif
> > +
> >  #define SK_MEM_QUANTUM_SHIFT ilog2(SK_MEM_QUANTUM)
> >  #define SK_MEM_SEND	0
> >  #define SK_MEM_RECV	1
> > 
> 
> What particular problem do you want to solve ?

So far there is no other problem besides the weird tcp_wmem.

> Wouldn't be easier to chose 4096 on all arches ?

Not sure what you're referring to. That config comes from a
distro kernel, so it's not under my control. If it is about
the upper limit for sk_mem_quantum, 4k seems enough to me as well.
 
> Are you sure a network driver doesn't provide skb using a full page ?

You lost me. You're saying that today we consider a page size
a minimum and so if we reduce that, the skb wouldn't fit in the
min sk memory?

Thanks,
-- 
fbl
