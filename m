From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Wed, 01 Apr 2015 18:53:50 -0700
Message-ID: <1427939630.25985.186.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
	 <CAHA+R7NvbJyjjBac=4VneQ_Nuxtb-_HEOJp0dujh5SOXj3NSKQ@mail.gmail.com>
	 <1427934458.25985.177.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1427934951.1893436.248333749.7DEEB94B@webmail.messagingengine.com>
	 <1427935725.25985.179.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1427936176.1899545.248339037.14F4C167@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34825 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbbDBBx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 21:53:59 -0400
Received: by pddn5 with SMTP id n5so73284422pdd.2
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 18:53:59 -0700 (PDT)
In-Reply-To: <1427936176.1899545.248339037.14F4C167@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-02 at 02:56 +0200, Hannes Frederic Sowa wrote:
> 
> On Thu, Apr 2, 2015, at 02:48, Eric Dumazet wrote:
> > On Thu, 2015-04-02 at 02:35 +0200, Hannes Frederic Sowa wrote:
> > > On Thu, Apr 2, 2015, at 02:27, Eric Dumazet wrote: 
> > > > orphaning skb just because they traverse a tunnel would be quite
> > > > horrible.
> > > 
> > > Agreed, but we have some bits in the skb->sk pointer left for signaling
> > > we are only keeping it around for destructor and upper layer
> > > notifications. Destructors should be the only ones having to deal with
> > > skb->sk and they can mask the bit. That would touch a lot of NULL
> > > checks, though.
> > 
> > Have you checked net/sched/sch_fq.c per chance ?
> > 
> > skb->sk is not an opaque value.
> 
> Do you think that skb->sk access through skb->__sk & ~0x1ULL would slow
> down the code too much?

I was only replying to your claim "Destructors should be the only ones
having to deal with skb->sk", which looked wrong to me.

Adding bit masking would slow down the code, but we did this already for
skb->dst
