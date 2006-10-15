From: Joan Raventos <jraventos@yahoo.com>
Subject: Re: poll problem with PF_PACKET when using PACKET_RX_RING
Date: Sun, 15 Oct 2006 11:10:59 -0700 (PDT)
Message-ID: <20061015181059.8920.qmail@web50601.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50601.mail.yahoo.com ([206.190.38.88]:2733 "HELO
	web50601.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1422661AbWJOSLB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2006 14:11:01 -0400
To: Patrick McHardy <kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

Thx for your prompt reply! Plz see some comments inline.

>> 
>> Is this a bug in PF_PACKET? Should the socket queue be
>> emptied by packet_set_ring (called via setsockopt when
>> PACKET_RX_RING is used) so the above cannot happen?
>> Should the user-space app drain the socket queue with
>> recvfrom prior to (4) -quite unlikely in practice-?


> I guess the best way is not to bind the socket before having
> completed setup. We could still flush the queue to make life
> easier for userspace, not sure about that ..

Even w/o bind, packet_create is doing a dev_add_pack, which I think will make pkts arrive to that socket (ie. in netif_receive_skb one can see the loops over the rcu for both ptype_all and type-specific which seem match whenever !ptype->dev || ptype->dev==skb->dev).

Also the packet_mmap.txt doc does not mention bind, which probably is more a mechanism to closely specify a dev than to signal socket readiness.

Salu2,
J.




