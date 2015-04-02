From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Thu, 02 Apr 2015 02:35:51 +0200
Message-ID: <1427934951.1893436.248333749.7DEEB94B@webmail.messagingengine.com>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
 <CAHA+R7NvbJyjjBac=4VneQ_Nuxtb-_HEOJp0dujh5SOXj3NSKQ@mail.gmail.com>
 <1427934458.25985.177.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@resnulli.us>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:50799 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752526AbbDBAfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 20:35:52 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 8A0C720A64
	for <netdev@vger.kernel.org>; Wed,  1 Apr 2015 20:35:48 -0400 (EDT)
In-Reply-To: <1427934458.25985.177.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, Apr 2, 2015, at 02:27, Eric Dumazet wrote:
> On Wed, 2015-04-01 at 17:06 -0700, Cong Wang wrote:
> 
> > Shouldn't these skb's be orphaned for tunnel cases? Or we still have
> > to keep skb->sk for other valid use?
> 
> skb should not be orphaned, until the very last stage.
> 
> Many layers depend on this, really.
> 
> Simply ask the question to yourself :
> 
> What if I do not associate skb to a socket at first. What possibly
> breaks ?
> 
> orphaning skb just because they traverse a tunnel would be quite
> horrible.

Agreed, but we have some bits in the skb->sk pointer left for signaling
we are only keeping it around for destructor and upper layer
notifications. Destructors should be the only ones having to deal with
skb->sk and they can mask the bit. That would touch a lot of NULL
checks, though.

Bye,
Hannes
