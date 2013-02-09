From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Poor TCP bandwidth between network namespaces
Date: Fri, 08 Feb 2013 17:54:55 -0800
Message-ID: <5115AC6F.50305@hp.com>
References: <20130204144320.GG1353@tostaky> <20130204225227.GC6898@order.stressinduktion.org> <1360373618.6696.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Emmanuel Jeanvoine <emmanuel.jeanvoine@inria.fr>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:27621 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760470Ab3BIBy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 20:54:58 -0500
In-Reply-To: <1360373618.6696.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2013 05:33 PM, Eric Dumazet wrote:
> On Mon, 2013-02-04 at 23:52 +0100, Hannes Frederic Sowa wrote:
>> On Mon, Feb 04, 2013 at 03:43:20PM +0100, Emmanuel Jeanvoine wrote:
>>> I'm wondering why the overhead is so high when performing TCP
>>> transfers between two network namespaces. Do you have any idea about
>>> this issue? And possibly, how to increase the bandwidth (without
>>> modifying the MTU on the veths) between network namespaces?
>>
>> You could try Eric's patch (already in net-next) and have a look at the rest
>> of the discussion:
>>
>> http://article.gmane.org/gmane.linux.network/253589
>
> Another thing to consider is the default MTU value :
>
> 65536 for lo, and 1500 for veth
>
> It easily explains half performance for veth
>
> One another thing is the tx-nocache-copy setting, this can explain some
> extra percents.

Whenever I want to avoid matters of MTU, I try going with a test that 
never sends anything larger than the smaller of the MTUs involved.  One 
such example might be (aggregate) netperf TCP_RR tests.  Matters of path 
length have a much more difficult time "hiding" from a TCP_RR (or 
UDP_RR) test than a bulk transfer test.

happy benchmarking,

rick jones
