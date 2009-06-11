From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC net 00/03]: dev_queue_xmit error propagation
Date: Thu, 11 Jun 2009 18:33:26 +0200
Message-ID: <4A3131D6.40807@trash.net>
References: <20090609161658.6730.59754.sendpatchset@x2.localnet> <20090611.031852.90563118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56148 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963AbZFKQd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 12:33:26 -0400
In-Reply-To: <20090611.031852.90563118.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue,  9 Jun 2009 18:16:59 +0200 (MEST)
> 
>> Currently the ->ndo_hard_start_xmit() callbacks are only permitted to return
>> one of the NETDEV_TX codes. This prevents any kind of error propagation for
>> virtual devices, like queue congestion of the underlying device in case of
>> layered devices, or unreachability in case of tunnels.
>>
>> These patches change the return conventions so hard_start_xmit() can return
>> a NETDEV_TX code, an errno code or a NET_XMIT code. This means it can
>> additionally to the NETDEV_TX codes simply return the value of dev_queue_xmit().
>>

> These changes look fine to me.
> 
> That one if() conditional checking 'ret' for three different
> properties is stretching the brain a bit.  Maybe you can
> encapsulate that sucker into an inline function with suitable
> comments.  That way when someone reads the test, it just says
> what it is looking for, rather than being some complicated
> set of tests.

Yeah, I mainly failed to come up with a suitable name, but I've now
moved it to an inline function called "dev_xmit_skb_consumed".
Better suggestions are still welcome though :)

> Once you fix that up and the problem Eric spotted in patch #3
> feel free to formally submit this.

I still need to verify that no drivers are using the raw values for
the NETDEV_TX codes since NETDEV_TX_LOCKED is using a different
value with my patch. I'll probably submit them later today.
