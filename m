From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Fri, 15 Aug 2014 03:04:01 +0200
Message-ID: <1408064641.867439.152913861.09367C24@webmail.messagingengine.com>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
 <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
 <1408064099.6804.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:51239 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbaHOBED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 21:04:03 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway1.nyi.internal (Postfix) with ESMTP id 546322A462
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 21:04:01 -0400 (EDT)
In-Reply-To: <1408064099.6804.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Aug 15, 2014, at 02:54, Eric Dumazet wrote:
> On Fri, 2014-08-15 at 02:43 +0200, Hannes Frederic Sowa wrote:
> 
> > Someone could use GRO to create packet trains to hide from intrustion
> > detection systems, which maybe are the main user of TPACKET_V3. I don't
> > think this is a good idea.
> 
> Presumably these tools already use a large enough bloc_size, and not a
> 4KB one ;)
> 
> Even without GRO, a jumbo frame (9K) can trigger the bug.

Sure, but if I would have written such a tool without knowledge of GRO I
would have queried at least the MTU. ;)
If an IDS allocates block_sizes below the MTU there is not much we can
do. But up to the MTU we should let GRO behave transparently and here we
violate this. There are also interfaces which extremely large MTUs but
at least they report the MTU size correctly to user space.

> I do not think we need to skb_gso_segment() for the cases user setup a
> really small bloc_size. This looks like a lot of consumed cycles (we
> even might have to recompute the TCP checksums)

Yes, I feared that, too. Attacker could specifically target a slow path.

Bye,
Hannes
