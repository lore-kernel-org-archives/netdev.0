From: Ben Greear <greearb@candelatech.com>
Subject: Re: 802.1q HW filter spammage in 3.7.2+ kernels.
Date: Wed, 16 Jan 2013 06:03:04 -0800
Message-ID: <50F6B318.2010707@candelatech.com>
References: <50F60404.3090605@candelatech.com> <1358316108.19956.82.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49464 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab3APODK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 09:03:10 -0500
In-Reply-To: <1358316108.19956.82.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2013 10:01 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> On Tue, 2013-01-15 at 17:36 -0800, Ben Greear wrote:
>> My kernel logs are full of this (I have 2000 macvlans).
>
> Are you using 2000 macvlans on the same device ? Interesting...

Well, in this case, we have 1000 mac-vlans on each of 2 1G
Ethernet ports, but 2000 on a single device has been used
as well.

>
> I am wondering how multicast/broadcast messages don't generate a huge
> load and packet drops, since we clone packets for every macvlan, and
> queue then to netif_rx()
>

I have added ARP patches to do a random retry timer to help spread
out the ARP requests a bit, at least.  The system is still sluggish
at times, but it does function.  With a fixed-interval ARP timer, things
can get into very bad patterns.

http://patchwork.ozlabs.org/patch/9301/

My test cases often require SO_BINDTODEVICE to function with full features,
with one traffic-application per interface, so mac-vlans seems the easiest
way to scale.

> I guess you dont use IPv6 on these macvlans ?

I have...but many use cases use far fewer (virtual) interfaces.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
