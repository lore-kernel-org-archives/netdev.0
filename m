From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH 1/3] net: sched: tbf: fix calculation of max_size
Date: Fri, 15 Nov 2013 15:23:21 +0800
Message-ID: <5285CBE9.8010100@huawei.com>
References: <1384419714-24364-1-git-send-email-yangyingliang@huawei.com>	 <1384419714-24364-2-git-send-email-yangyingliang@huawei.com> <1384439910.28458.152.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:38782 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757907Ab3KOH1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 02:27:38 -0500
In-Reply-To: <1384439910.28458.152.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/14 22:38, Eric Dumazet wrote:
> On Thu, 2013-11-14 at 17:01 +0800, Yang Yingliang wrote:
>> Current max_size is caluated from rate table.
>> Now, the rate table has been replaced and it's
>> not proper to caculate max_size with rate64.
>> Use psched_ns_t2l to calculate the max_size.
>>
>> psched_ns_t2l():convert time in ns to length in
>> bytes which to determinate how many bytes can be
>> sent in given time.
> 
> I have no evidence you fix a real bug.
> 
> Please provide a tc script and show us it breaks.
> 
> Also CC Jesper you wrote this code.

I'm sorry I made a mistake in my early description.

Here is the bug's description.
With the follow command:
tc qdisc add dev eth1 root handle 1: tbf latency 50ms burst 10KB rate 30gbit mtu 64k

Without this patch, the max_size value is 10751(bytes).
But, in fact, the real max_size value should be smaller than 7440(bytes).
Or a packet whose length is bigger than 7440 will cause network congestion.
Because the packet is so big that can't get enough tokens. Even all the tokens
in the buffer is given to the packet.

With this patch, the max_size value is 7440(bytes).
The packets whose length is bigger than 7440(bytes) will be dropped or reshape
in tbf_enqueue().

Regards,
Yang

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
