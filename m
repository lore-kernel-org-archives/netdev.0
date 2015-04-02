From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Thu, 02 Apr 2015 13:34:08 +0200
Message-ID: <1427974448.2093675.248500389.6D8AFBB6@webmail.messagingengine.com>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
 <CAHA+R7NvbJyjjBac=4VneQ_Nuxtb-_HEOJp0dujh5SOXj3NSKQ@mail.gmail.com>
 <1427934458.25985.177.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427934951.1893436.248333749.7DEEB94B@webmail.messagingengine.com>
 <1427935725.25985.179.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427936176.1899545.248339037.14F4C167@webmail.messagingengine.com>
 <1427939630.25985.186.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:58998 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751166AbbDBLeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 07:34:10 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id C851F20A28
	for <netdev@vger.kernel.org>; Thu,  2 Apr 2015 07:34:05 -0400 (EDT)
In-Reply-To: <1427939630.25985.186.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 2, 2015, at 03:53, Eric Dumazet wrote:
> On Thu, 2015-04-02 at 02:56 +0200, Hannes Frederic Sowa wrote:
> > 
> > On Thu, Apr 2, 2015, at 02:48, Eric Dumazet wrote:
> > > On Thu, 2015-04-02 at 02:35 +0200, Hannes Frederic Sowa wrote:
> > > > On Thu, Apr 2, 2015, at 02:27, Eric Dumazet wrote: 
> > > > > orphaning skb just because they traverse a tunnel would be quite
> > > > > horrible.
> > > > 
> > > > Agreed, but we have some bits in the skb->sk pointer left for signaling
> > > > we are only keeping it around for destructor and upper layer
> > > > notifications. Destructors should be the only ones having to deal with
> > > > skb->sk and they can mask the bit. That would touch a lot of NULL
> > > > checks, though.
> > > 
> > > Have you checked net/sched/sch_fq.c per chance ?
> > > 
> > > skb->sk is not an opaque value.
> > 
> > Do you think that skb->sk access through skb->__sk & ~0x1ULL would slow
> > down the code too much?
> 
> I was only replying to your claim "Destructors should be the only ones
> having to deal with skb->sk", which looked wrong to me.

You are correct, there might be even more places I need to use this. 

> Adding bit masking would slow down the code, but we did this already for
> skb->dst

Exactly.

My plan is that I actually would propose this patch for -net and stable
as it fixes the problem that currently we oops when running dhclient on
a vxlan interface. As soon as net gets merged into net-next I I would
propose this change if it works out smoothly and looks maintainable.

Thanks,
Hannes
