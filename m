From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 02:55:35 +0200
Message-ID: <20060630005535.GD14627@postel.suug.ch>
References: <1151626099.8922.64.camel@jzny2> <20060629.171215.112621072.davem@davemloft.net> <1151627180.8922.81.camel@jzny2> <20060629.172948.59656719.davem@davemloft.net> <1151628520.8922.99.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:6053 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964832AbWF3AzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 20:55:15 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151628520.8922.99.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-29 20:48
> the ifb references it; only mirred redirects to the ifb at the moment.
> You would need to increment in mirred, no?
> Why do i feel i am missing something? ;->

The point is to avoid having an atomic operation for every packet
when setting iif in netif_receive_skb(). If it was only for
mirred nobody would complain I guess.

> I think whether it becomes ifindex or pointer you need to increment the
> refcounter. and decrement somewhere.
> The challenge for me is a choice to use more cycles if you use ifindex
> vs less cycles with a pointer. The advantage for going with ifindex
> would be to save those bits(if you rearrange). The question is which is
> reasonable?;->

The third choice is to just don't care if the interface goes away
but have a chance to figure it out and just assume as if it would
have never been set. The number of devices that can disappear w/o
user control is very very limited and not worth an atomic operation
for every single packet.
