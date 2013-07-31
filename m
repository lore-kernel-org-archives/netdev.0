From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netem: Introduce skb_orphan_partial() helper
Date: Tue, 30 Jul 2013 20:27:03 -0700
Message-ID: <1375241223.10515.62.camel@edumazet-glaptop>
References: <1375232108.10515.47.camel@edumazet-glaptop>
	 <kt9vrt$occ$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:53071 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696Ab3GaD1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 23:27:05 -0400
Received: by mail-pa0-f44.google.com with SMTP id jh10so332549pab.3
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 20:27:04 -0700 (PDT)
In-Reply-To: <kt9vrt$occ$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 03:21 +0000, Cong Wang wrote:
> On Wed, 31 Jul 2013 at 00:55 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index b9f2b09..53d4714 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -1520,6 +1520,7 @@ extern struct sk_buff		*sock_rmalloc(struct sock *sk,
> >  					      unsigned long size, int force,
> >  					      gfp_t priority);
> >  extern void			sock_wfree(struct sk_buff *skb);
> > +extern void			skb_orphan_partial(struct sk_buff *skb);
> >  extern void			sock_rfree(struct sk_buff *skb);
> >  extern void			sock_edemux(struct sk_buff *skb);
> >  
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 85e8de1..a753d97 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1576,6 +1576,25 @@ void sock_wfree(struct sk_buff *skb)
> >  }
> >  EXPORT_SYMBOL(sock_wfree);
> >  
> > +void skb_orphan_partial(struct sk_buff *skb)
> 
> I think net/core/skbuff.c is a better place to put this (or skbuff.h
> if it can be inlined).

I put it right after sock_wfree() because this stuff really has to make
the same thing than sock_wfree().

I do not want to inline it because EXPORTing tcp_wfree() looks ugly.
