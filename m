From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
Date: Thu, 24 Jan 2013 13:01:35 -0800
Message-ID: <5101A12F.3040002@candelatech.com>
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>  <1358875020.3464.4006.camel@edumazet-glaptop>  <1358875607.3464.4020.camel@edumazet-glaptop>  <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>  <5100785D.8040101@candelatech.com>  <1358985688.12374.1247.camel@edumazet-glaptop>  <51007CA8.2050105@candelatech.com>  <1358987031.12374.1276.camel@edumazet-glaptop>  <51008294.2010201@candelatech.com>  <1358988358.12374.1303.camel@edumazet-glaptop>  <51008598.4000603@candelatech.com>  <1358989242.12374.1323.camel@edumazet-glaptop>  <51008900.2010803@candelatech.com>  <1358989843.12374.1334.camel@edumazet-glaptop>  <1358991906.
 12374.1356.camel@edumazet-glaptop>  <51019397.90304@candelatech.com> <1359061140.12374.2395.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46333 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755905Ab3AXVBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 16:01:38 -0500
In-Reply-To: <1359061140.12374.2395.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2013 12:59 PM, Eric Dumazet wrote:
> On Thu, 2013-01-24 at 12:03 -0800, Ben Greear wrote:
>> iately processed (and loopback device is hard wired ?)
>>
>> I have not seen any crashes since this change went into my
>> test bed, so I believe this one is finally fixed!  I'm running
>> with your macvlan fixes as well..and even if they did not
>> fix the problem I saw, they at least appear to cause no harm.
>>
>> If you wish, feel free to add:
>>
>> Tested-By:  Ben Greear <greearb@candelatech.com>
>>
>> Thanks,
>> Ben
>
> Just to make sure, you still have the
>
> WARN_ON_ONCE(skb_dst_is_noref(skb))
>
> in netif_rx() ?
>

I have something similar, and I have not seen any splats:

int netif_rx(struct sk_buff *skb)
{
	int ret;

	WARN_ON(skb->_skb_refdst & SKB_DST_NOREF);


I'll keep this in our kernels so when we do .1q vlans and other
sorts of testing we'll get some more coverage.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
