From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Mon, 22 Oct 2012 17:47:54 -0400
Message-ID: <5085BF0A.2030602@hp.com>
References: <508123AC.5080208@parallels.com>  <50858ABD.2000206@hp.com>  <1350938702.8609.1299.camel@edumazet-glaptop>  <5085B8B0.6010500@hp.com> <1350941831.8609.1355.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:16868 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755865Ab2JVVr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 17:47:58 -0400
In-Reply-To: <1350941831.8609.1355.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2012 05:37 PM, Eric Dumazet wrote:
> On Mon, 2012-10-22 at 17:20 -0400, Brian Haley wrote:
> 
>> It's not much different from what's there:
>>
>> 	setsockopt("foo");
>>
>> 	rename foo -> bar
>>
>> 	index = getsockopt();
>> 	if_indextoname(index) -> "bar"
>>
>> I more raised the issue since you pass a 'char *' to setsockopt() but an 'int *'
>> to getsockopt(), I don't think any other value is non-symmetrical like this.
>>
>> -Brian
> 
> I meant another cpu can be changing dev->name[] content while the
> strcpy() is done, and you get a mangled devname, like "for" or "bao"
> instead of "foo" or "bar"

Even when holding the rcu_read_lock()?  I'd have to hold the rtnl lock there?

-Brian
