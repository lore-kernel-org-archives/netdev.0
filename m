From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue immediately
 after it's detached from sk
Date: Mon, 11 Apr 2016 22:42:41 +0800
Message-ID: <570BB7E1.5070004@huawei.com>
References: <1460040665.6473.398.camel@edumazet-glaptop3.roam.corp.google.com>
 <5707939B.2030907@huawei.com>
 <1460126665.6473.437.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160408.125336.1805413467131988444.davem@davemloft.net>
 <1460135072.6473.441.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <dingtianhong@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([58.251.152.52]:38036 "EHLO
	szxga04-in.huawei.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753641AbcDKOoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 10:44:01 -0400
In-Reply-To: <1460135072.6473.441.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/4/9 1:04, Eric Dumazet wrote:
> On Fri, 2016-04-08 at 12:53 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 08 Apr 2016 07:44:25 -0700
>>
>>> On Fri, 2016-04-08 at 19:18 +0800, Yang Yingliang wrote:
>>>
>>>> I expand  tcp_adv_win_scale and tcp_rmem. It has no effect.
>>>
>>> Try :
>>>
>>> echo -2 >/proc/sys/net/ipv4/tcp_adv_win_scale
>>>
>>> And restart your flows.
>>
>> I'm honestly beginning to suspect a bug in their driver and how they
>> handle skb->truesize.
>>
>> Yang, until you show us the driver you are using and how is handles
>> receive packets, we are largely in the dark about a major component
>> of this issue and that is entirely unfair to us.
>
> Apparently their skb->truesize and skb->len combinations are correct.
>
> I suspect an issue with rcvbuf autouning on a bidirectional tcp traffic.
> We mostly focus on unidirectional flows, but they seem to use a mixed
> case.
>
> Also, fact that sendmsg() locks the socket for the duration of the call
> is problematic : I suspect their issues would mostly disappear by using
> smaller chunk sizes (ie 64KB per sendmsg() instead of 256KB).
It's less packets dropping with using 64KB chunk.

>
> We also could add resched points in sendmsg() (processing backlog if it
> gets too hot), but I fear this would slow down the fast path.
>
>
>
>
>
