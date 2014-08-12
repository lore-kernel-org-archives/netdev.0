From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: netlink_deliver_tap is broken
Date: Tue, 12 Aug 2014 21:19:07 +0200
Message-ID: <53EA68AB.6020700@redhat.com>
References: <36718D51-62DE-40B4-AE97-F82F3704597C@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754687AbaHLTTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 15:19:13 -0400
In-Reply-To: <36718D51-62DE-40B4-AE97-F82F3704597C@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/11/2014 11:38 PM, Marcel Holtmann wrote:
...
> the netlink tap functionality is not really usable. At least not from a nlmon perspective. It has three fundamental problems.
>
> a) Multicast netlink messages are not delivered to a registered tap when you do not have any member subscribed to the multicast group
>
> b) Multicast netlink messages are delivered multiple times when you have multiple clients subscribed to that multicast group.

The rationale so far I had in mind was that the tap only gets messages
that actually reach another socket/endpoint through netlink. Perhaps
analogous to non-promisc mode ... I think otherwise it's quite hard to
tell if a client actually got a message or not. E.g. it would for some
reason screw up the subscribe, and you could not tell if the netlink
skb actually landed validly in the receive queue. Perhaps we could make
a difference in that behaviour when nlmon is put into promisc mode?

> c) Unicast netlink messages are filtered out by the client socket filter meaning they never get to the tap

Do you mean BPF filter on the packet socket? What filter program do you
have attached and in what scenario?
