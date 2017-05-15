From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 3/3] udp: keep the sk_receive_queue held when
 splicing
Date: Mon, 15 May 2017 22:22:57 +0200
Message-ID: <1494879777.3586.21.camel@redhat.com>
References: <1494865864.3586.19.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45910 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965496AbdEOUXB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 16:23:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-15 at 09:11 -0700, Eric Dumazet wrote:
> On Mon, 2017-05-15 at 11:01 +0200, Paolo Abeni wrote:
> > On packet reception, when we are forced to splice the
> > sk_receive_queue, we can keep the related lock held, so
> > that we can avoid re-acquiring it, if fwd memory
> > scheduling is required.
> > 
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  net/ipv4/udp.c | 36 ++++++++++++++++++++++++++----------
> >  1 file changed, 26 insertions(+), 10 deletions(-)
> > 
> > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > index 492c76b..d698973 100644
> > --- a/net/ipv4/udp.c
> > +++ b/net/ipv4/udp.c
> > @@ -1164,7 +1164,8 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
> >  }
> >  
> >  /* fully reclaim rmem/fwd memory allocated for skb */
> > -static void udp_rmem_release(struct sock *sk, int size, int partial)
> > +static void udp_rmem_release(struct sock *sk, int size, int partial,
> > +			     int rx_queue_lock_held)
> 
> Looks good, but please use a bool rx_queue_lock_held ?

oops, I wrongly omitted some most recipients in my initial reply, re-
sending. Eric, I'm sorry for the duplicates.

ok, it sounds cleaner, I will submit a v2.

Thank you for reviewing this!

Cheers,

Paolo
