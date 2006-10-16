From: Patrick McHardy <kaber@trash.net>
Subject: Re: poll problem with PF_PACKET when using PACKET_RX_RING
Date: Mon, 16 Oct 2006 08:18:17 +0200
Message-ID: <45332429.3090000@trash.net>
References: <20061015181059.8920.qmail@web50601.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:19361 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030306AbWJPGSV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 02:18:21 -0400
To: Joan Raventos <jraventos@yahoo.com>
In-Reply-To: <20061015181059.8920.qmail@web50601.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joan Raventos wrote:
>>>Is this a bug in PF_PACKET? Should the socket queue be
>>>emptied by packet_set_ring (called via setsockopt when
>>>PACKET_RX_RING is used) so the above cannot happen?
>>>Should the user-space app drain the socket queue with
>>>recvfrom prior to (4) -quite unlikely in practice-?
> 
>
>>I guess the best way is not to bind the socket before having
>>completed setup. We could still flush the queue to make life
>>easier for userspace, not sure about that ..
> 
> 
> Even w/o bind, packet_create is doing a dev_add_pack, which I think will make pkts arrive to that socket (ie. in netif_receive_skb one can see the loops over the rcu for both ptype_all and type-specific which seem match whenever !ptype->dev || ptype->dev==skb->dev).
> 
> Also the packet_mmap.txt doc does not mention bind, which probably is more a mechanism to closely specify a dev than to signal socket readiness.

packet_create only calls dev_add_pack if a protocol is given.
You can use a protocol number of 0 and then bind the socket
after setting it up properly.

According to your description, you first used setsockopt(...,
PACKET_RX_RING), then mmap. In that case the receive queue
should already get flushed by packet_set_ring (about line 1710).
How did you verify that the receive queue still contains packets?

