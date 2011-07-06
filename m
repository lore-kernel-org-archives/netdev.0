From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] AF_PACKET fanout support
Date: Tue, 05 Jul 2011 20:19:50 -0700 (PDT)
Message-ID: <20110705.201950.199250194399828543.davem@davemloft.net>
References: <CA+mtBx_MtQGqNT6iungW7eyStpvLEGYsgXQ8=mYq_JR8jw3=DQ@mail.gmail.com>
	<20110705.182041.1392492274453963565.davem@davemloft.net>
	<CA+mtBx8www2eNp38EDuagYMQGSYivG7SN4ffozz4QtZPZqubSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: victor@inliniac.net, netdev@vger.kernel.org, willemb@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838Ab1GFDUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 23:20:00 -0400
In-Reply-To: <CA+mtBx8www2eNp38EDuagYMQGSYivG7SN4ffozz4QtZPZqubSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 5 Jul 2011 20:13:27 -0700

>>> Also, another useful mode of steering would be to steer packets to a
>>> socket which was recently processed by a thread running on the same
>>> CPU; somewhat analogous to RFS (cc'ed WIllem Bruijn who is already
>>> working on this I believe).
>>
>> This sounds like a good way to overload a local socket and prevent
>> pushing the work to lesser used sockets on other cpus.
>>
> Sure, it you're not using RPS or RSS!  These should already be
> distributing the RX work amongst CPUs.

One idea I did have while working on the PACKET_FANOUT bits was
to allow a packet socket to be bound to a particular cpu.  And
to implement this we'd have a per-cpu list of packet_type taps.

But in order for the user to make sure he gets all the traffic,
he'd have to make sure he bound one AF_PACKET socket to every
online cpu and then listened for all cpu hotplug events.

It doesn't really work.
