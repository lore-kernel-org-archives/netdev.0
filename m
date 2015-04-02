From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Thu, 02 Apr 2015 02:56:16 +0200
Message-ID: <1427936176.1899545.248339037.14F4C167@webmail.messagingengine.com>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
 <CAHA+R7NvbJyjjBac=4VneQ_Nuxtb-_HEOJp0dujh5SOXj3NSKQ@mail.gmail.com>
 <1427934458.25985.177.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427934951.1893436.248333749.7DEEB94B@webmail.messagingengine.com>
 <1427935725.25985.179.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:45474 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751056AbbDBA4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 20:56:17 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 0DDB120B10
	for <netdev@vger.kernel.org>; Wed,  1 Apr 2015 20:56:13 -0400 (EDT)
In-Reply-To: <1427935725.25985.179.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, Apr 2, 2015, at 02:48, Eric Dumazet wrote:
> On Thu, 2015-04-02 at 02:35 +0200, Hannes Frederic Sowa wrote:
> > On Thu, Apr 2, 2015, at 02:27, Eric Dumazet wrote: 
> > > orphaning skb just because they traverse a tunnel would be quite
> > > horrible.
> > 
> > Agreed, but we have some bits in the skb->sk pointer left for signaling
> > we are only keeping it around for destructor and upper layer
> > notifications. Destructors should be the only ones having to deal with
> > skb->sk and they can mask the bit. That would touch a lot of NULL
> > checks, though.
> 
> Have you checked net/sched/sch_fq.c per chance ?
> 
> skb->sk is not an opaque value.

Do you think that skb->sk access through skb->__sk & ~0x1ULL would slow
down the code too much?
