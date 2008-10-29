From: Patrick McHardy <kaber@trash.net>
Subject: Re: New filter 'flow' bug?
Date: Wed, 29 Oct 2008 09:15:33 +0100
Message-ID: <49081BA5.5070401@trash.net>
References: <20081029072705.376AC1E3087@f03.poczta.interia.pl> <20081029.003713.193704291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: almaop@poczta.fm
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59014 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbYJ2IPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 04:15:36 -0400
In-Reply-To: <20081029.003713.193704291.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: almaop@poczta.fm
> Date: 29 Oct 2008 08:27:05 +0100
>> My configuration: gentoo, kernel 2.6.26.7 + imq patch + l7 patch, glibc 2.7, iproute2 2.6.26. Shaping is done on ethernet (e1000 card) but as I see on the ifb nothing changes.
>> There are htb 3 classes with sfq as their qdiscs. It is simple, something like:
>>
>> tc qdisc add dev $DEV root handle 1: htb default 4 tc class add dev $DEV parent 1: classid 1:1 htb rate 78kbps ceil 78kbps overhead 0 linklayer atm
>>
>> tc class add dev $DEV parent 1:1 classid 1:2 htb rate 20kbps ceil 20kbps overhead 0 linklayer atm prio 3
>> tc class add dev $DEV parent 1:1 classid 1:3 ...
>> tc class add dev $DEV parent 1:1 classid 1:4 ...
>>  
>> tc qdisc add dev $DEV parent 1:2 handle 2: sfq quantum 64
>> tc qdisc add dev $DEV parent 1:3 handle 3: sfq
>> tc qdisc add dev $DEV parent 1:4 handle 4: sfq
>>
>> tc filter add dev $DEV parent 1: ....
>> ....
>>  
>> tc filter add dev $DEV parent 2: protocol ip handle 1 prio 12 flow \
>> hash keys dst,proto,proto-dst divisor 128
>>
>> tc filter add dev $DEV parent 3: protocol ip handle 1 prio 12 flow \
>> hash keys dst,proto,proto-dst divisor 128
>>
>> tc filter add dev $DEV parent 4: protocol ip handle 1 prio 12 flow \
>> hash keys nfct-src,nfct-dst,proto,nfct-proto-src,nfct-proto-dst divisor 128
>>
>> I'm not sure where is the bug - in the flow filter or in the sfq qdisc.

Which SFQ qdisc is stalling?
