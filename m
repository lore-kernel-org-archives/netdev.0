From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Fri, 15 Aug 2014 02:43:58 +0200
Message-ID: <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:52712 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750749AbaHOAoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 20:44:00 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway1.nyi.internal (Postfix) with ESMTP id DE3B52A219
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 20:43:58 -0400 (EDT)
In-Reply-To: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Fri, Aug 15, 2014, at 02:09, Eric Dumazet wrote:
> It looks like PACKET_V3 has no check that a packet can always fit in a
> block.
> 
> Its trivial with GRO to break the assumption and write into kernel
> memory.
> 
> [...]
>
> Not sure how to fix this.
> 
> This patch only shows where the problem is, but should we :
> 
> 1) drop the too long packet

Someone could use GRO to create packet trains to hide from intrustion
detection systems, which maybe are the main user of TPACKET_V3. I don't
think this is a good idea.

> 2) clamp size to maximal admissible size

Maybe.

> 3) other solution ? (PACKET_V2 can queue a clone of skb in
> receive_queue, but PACKET_V3 has no such capability)

4) Can we still try to skb_gso_segment the packet again? Not nice, but I
guess this will work. Maybe depending on a tunable (default to on)?

Bye,
Hannes
