From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Fri, 15 Aug 2014 02:50:59 +0200
Message-ID: <1408063859.864295.152910193.45470221@webmail.messagingengine.com>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
 <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
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
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:53424 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750749AbaHOAu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 20:50:59 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway1.nyi.internal (Postfix) with ESMTP id 3F69328CDD
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 20:50:59 -0400 (EDT)
In-Reply-To: <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another thought...

On Fri, Aug 15, 2014, at 02:43, Hannes Frederic Sowa wrote:
> On Fri, Aug 15, 2014, at 02:09, Eric Dumazet wrote:
> > It looks like PACKET_V3 has no check that a packet can always fit in a
> > block.
> > 
> > Its trivial with GRO to break the assumption and write into kernel
> > memory.
>
> [...]
>
> 4) Can we still try to skb_gso_segment the packet again? Not nice, but I
> guess this will work. Maybe depending on a tunable (default to on)?

5) Or let a setsockopt control the NETIF_F_GRO bit of an interface if it
is bound to it? This will likely result in an implementation where we
must count current TPACKET_V3 sockets disabling GRO on an interface,
much like promisc counter.

Bye,
Hannes
