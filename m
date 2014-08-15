From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] packet: handle too big packets for PACKET_V3
Date: Fri, 15 Aug 2014 04:08:13 +0200
Message-ID: <1408068493.883799.152927037.00E71092@webmail.messagingengine.com>
References: <1408061394.6804.55.camel@edumazet-glaptop2.roam.corp.google.com>
 <1408063438.861699.152907025.0F25AB17@webmail.messagingengine.com>
 <1408064099.6804.64.camel@edumazet-glaptop2.roam.corp.google.com>
 <1408064641.867439.152913861.09367C24@webmail.messagingengine.com>
 <1408068085.6804.75.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:32950 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751763AbaHOCIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 22:08:18 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway1.nyi.internal (Postfix) with ESMTP id 39A0F2A43F
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 22:08:13 -0400 (EDT)
In-Reply-To: <1408068085.6804.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2014, at 04:01, Eric Dumazet wrote:
> On Fri, 2014-08-15 at 03:04 +0200, Hannes Frederic Sowa wrote:
> 
> > Sure, but if I would have written such a tool without knowledge of GRO I
> > would have queried at least the MTU. ;)
> 
> Would all existing tools react to a mtu change properly ?
> 
> (It would have to reinit its af_packet ring)
> 
> I do not think its a GRO issue, really, but an optimistic PACKET_V3
> implementation. GRO was already there when PACKET_V3 was added.
> 
> Even a non GRO packet might not fit and we need to avoid the
> crash/corruption.
> 
> I believe I am going to implement 2)  (clamp the snaplen)

Ok, cool, I think this is the best way forward for now.

Do you think a a printk_once if the packet gets clamped because of GRO
would be sensible with a hint that GRO could be disabled in such cases?

> An application should catch that tp_len might be bigger than tp_snaplen
> and eventually do something sensible about it.
> 
> BTW, tp_sizeof_priv doesnt look to be checked at all, user input is
> accepted as is.

Hmm...

Bye,
Hannes
