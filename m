From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Tue, 23 Oct 2012 17:43:23 -0400
Message-ID: <50870F7B.3010805@hp.com>
References: <508123AC.5080208@parallels.com>  <50858ABD.2000206@hp.com>  <1350938702.8609.1299.camel@edumazet-glaptop>  <5085B8B0.6010500@hp.com>  <1350941831.8609.1355.camel@edumazet-glaptop>  <5085BF0A.2030602@hp.com> <1350942738.8609.1375.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:36443 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334Ab2JWVn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 17:43:28 -0400
In-Reply-To: <1350942738.8609.1375.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2012 05:52 PM, Eric Dumazet wrote:

>>> I meant another cpu can be changing dev->name[] content while the
>>> strcpy() is done, and you get a mangled devname, like "for" or "bao"
>>> instead of "foo" or "bar"
>>
>> Even when holding the rcu_read_lock()?  I'd have to hold the rtnl lock there?
> 
> Yes, rcu_read_lock() only makes sure the device doesnt disappear.
> 
> But its name can be changed.

There's a similar bug in the SIOCGIFNAME/dev_ifname() code too then, but I would
think this rare enough that it doesn't happen in practice.

-Brian
