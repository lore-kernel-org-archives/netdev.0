From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Mon, 13 Jan 2014 11:59:13 -0800 (PST)
Message-ID: <20140113.115913.1269834557058575064.davem@davemloft.net>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	<1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaAMT7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:59:14 -0500
In-Reply-To: <CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 10 Jan 2014 08:27:20 -0800

> On Thu, Jan 9, 2014 at 9:38 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2014-01-09 at 20:54 -0800, Tom Herbert wrote:
>>> When initializing a gro_list for a packet, first check the rxhash of
>>> the incoming skb against that of the skb's in the list. This should be
>>> a very strong inidicator of whether the flow is going to be matched,
>>> and potentially allows a lot of other checks to be short circuited.
>>>
>>
>> Hmm... this idea was discussed in the past. I used it when attempting to
>> use a hash table instead of a gro_list last year.
>>
>> Unfortunately this added lot of cycles when rxhash is not provided by
>> hardware, and my tests found it was not a win.
>>
>> Remember : in most cases, gro_list contains one flow, so this test does
>> nothing special but adds overhead.
> 
> I don't understand what your basis is that gro_list in most cases
> contains one flow

It also doesn't jive well with Eric's recent patch to adjust the GRO
overflow strategy (600adc18eba823f9fd8ed5fec8b04f11dddf3884 ("net:
gro: change GRO overflow strategy"))

:-)

I sort of like Tom's idea to optimistically compare the hash, if we
do in fact have one already.

Eric would the change be OK if Tom did it that way?
