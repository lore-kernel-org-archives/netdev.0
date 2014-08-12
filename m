From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: netlink_deliver_tap is broken
Date: Tue, 12 Aug 2014 12:40:43 -0700
Message-ID: <C8130F14-4030-44DB-BC4C-2931C501D121@holtmann.org>
References: <36718D51-62DE-40B4-AE97-F82F3704597C@holtmann.org> <53EA68AB.6020700@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:47279 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929AbaHLTkH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 15:40:07 -0400
In-Reply-To: <53EA68AB.6020700@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

>> the netlink tap functionality is not really usable. At least not from a nlmon perspective. It has three fundamental problems.
>> 
>> a) Multicast netlink messages are not delivered to a registered tap when you do not have any member subscribed to the multicast group
>> 
>> b) Multicast netlink messages are delivered multiple times when you have multiple clients subscribed to that multicast group.
> 
> The rationale so far I had in mind was that the tap only gets messages
> that actually reach another socket/endpoint through netlink. Perhaps
> analogous to non-promisc mode ... I think otherwise it's quite hard to
> tell if a client actually got a message or not. E.g. it would for some
> reason screw up the subscribe, and you could not tell if the netlink
> skb actually landed validly in the receive queue. Perhaps we could make
> a difference in that behaviour when nlmon is put into promisc mode?

this makes no sense to me. If the client screws up, then nobody knows if the message was sent. The kernel will just filter it out. That is pretty much useless.

What I want is that you can use the monitoring tool to check that the multicast message actually was send. That is the only sane way to do this. And since this is a TAP device, that is what it should do. I have no idea why you would put promiscuous mode in the mix here.

The multiple deliveries of the multicast messages is also useless. It makes no sense to see that it reached 10 clients, because I have 10 clients subscribed to the RTNL multicast messages. I can not distinguish these 10 messages since they are all identical once they reach nlmon. It will look like the kernel is misbehaving and sending messages multiple times.

While it does send one to each socket, but why would you care how many times the kernel delivered the exactly same message. I care that the kernel has a multicast message to deliver. If it delivered it 0 or 100 times in the end is of no use.

>> c) Unicast netlink messages are filtered out by the client socket filter meaning they never get to the tap
> 
> Do you mean BPF filter on the packet socket? What filter program do you
> have attached and in what scenario?

Yes, if you open a netlink socket and use SO_FILTER. If the messages never reaches the client socket, you also never see it via nlmon. Again, this is pretty much useless. If I want to use nlmon to see what is actually going on, then I need it to give me all netlink messages going in and out of the kernel.

The current netlink TAP functionality is way too limited to be useful when you try to debug your system and see what clients and kernel is exchanging over netlink.

Regards

Marcel
