From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH] net: sched: tbf: fix calculation of max_size
Date: Tue, 26 Nov 2013 10:35:19 +0800
Message-ID: <529408E7.3060001@huawei.com>
References: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>		 <1384845939-8424-2-git-send-email-yangyingliang@huawei.com>	 <1385233579.10637.95.camel@edumazet-glaptop2.roam.corp.google.com>	 <5291AA8D.6060108@gmail.com> <1385318452.10637.116.camel@edumazet-glaptop2.roam.corp.google.com> <5292C76E.1070701@huawei.com> <52933CC7.9070805@huawei.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7443@saturn3.aculab.com> <5293F92F.606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:29419 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232Ab3KZCf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 21:35:59 -0500
In-Reply-To: <5293F92F.606@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/26 9:28, Yang Yingliang wrote:
> On 2013/11/25 20:22, David Laight wrote:
>>> From: Yang Yingliang <yangyingliang@huawei.com>
>>>
>>> Current max_size is caluated from rate table. Now, the rate table
>>> has been replaced and it's wrong to caculate max_size based on this
>>> rate table. It can lead wrong calculation of max_size.
>>>
>>> The burst in kernel may be lower than user asked, because burst may gets
>>> some loss when transform it to buffer(E.g. "burst 40kb rate 30mbit/s")
>>> and it seems we cannot avoid this loss. And burst's value(max_size) based
>>> on rate table may be equal user asked. If a packet's length is max_size,
>>> this packet will be stalled in tbf_dequeue() because its length is above
>>> the burst in kernel so that it cannot get enough tokens. The max_size guards
>>> against enqueuing packet sizes above q->buffer "time" in tbf_enqueue().
>>
>> Why not adjust the calculations so that the number of allocated tokens
>> can go negative?
>>
>> So allow the transfer if the number of tokens is +ve and then subtract
>> the number needed for the message itself.
> 
> Thanks for your advice!
> I had considered it before. But, I think that we calculate tokens from ns
> but max_size is calculated based on rate table causes the problem. I think we
> should make them consistent.
> 

Forgot to say, fixing calculation of max_size is also needed by 64bit rates.

Regards,
Yang
