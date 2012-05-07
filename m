From: Deng-Cheng Zhu <dczhu@mips.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Mon, 7 May 2012 14:51:06 +0800
Message-ID: <4FA770DA.6000104@mips.com>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>	 <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>	 <4FA35A3D.8000205@mips.com> <1336117669.3752.49.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns0.mips.com ([12.201.5.70]:39200 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753958Ab2EGGvK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 02:51:10 -0400
In-Reply-To: <1336117669.3752.49.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2012 03:47 PM, Eric Dumazet wrote:
> On Fri, 2012-05-04 at 12:25 +0800, Deng-Cheng Zhu wrote:
>> On 05/04/2012 11:22 AM, Tom Herbert wrote:
>>>> +struct cpu_flow {
>>>> +       struct net_device *dev;
>>>> +       u32 rxhash;
>>>> +       unsigned long ts;
>>>> +};
>>>
>>> This seems like overkill, we already have the rps_flow_table and this
>>> used in accelerated RFS so the device can also take advantage of
>>> steering.
>>
>> I think the mechanisms of rps_dev_flow_table and cpu_flow (in this
>> patch) are different: The former works along with rps_sock_flow_table
>> whose CPU info is based on recvmsg by the application. But for the tests
>> like what I did, there's no application involved.
>>
>>
>> Deng-Cheng
>
> I really suggest you speak with MIPS arch maintainers about these IRQ
> being all serviced by CPU0.

This is not about arch, it's about system design. Even with IRQ affinity
working, for single queue NICs, RPS still has its value in this test.

>
> Adding tweaks in network stack to lower the impact of this huge problem
> is a no go.

This is merely an option, to whom care about sparse flow throughput. And
it's absolutely sort of tradeoff, and not selected by default.


Deng-Cheng
