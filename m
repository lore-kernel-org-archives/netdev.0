From: Deng-Cheng Zhu <dczhu@mips.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Mon, 7 May 2012 16:01:35 +0800
Message-ID: <4FA7815F.8030101@mips.com>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>	 <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>	 <4FA35A3D.8000205@mips.com>	 <CA+mtBx-CErRU=3ewkAjVrGN3dGzjsTz8Q-E8J+Xa+529OVEvwA@mail.gmail.com>	 <4FA77051.20804@mips.com> <1336376282.3752.2252.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns0.mips.com ([12.201.5.70]:55224 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755349Ab2EGIBm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 04:01:42 -0400
In-Reply-To: <1336376282.3752.2252.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2012 03:38 PM, Eric Dumazet wrote:
> On Mon, 2012-05-07 at 14:48 +0800, Deng-Cheng Zhu wrote:
>> On 05/04/2012 11:31 PM, Tom Herbert wrote:
>>>> I think the mechanisms of rps_dev_flow_table and cpu_flow (in this
>>>> patch) are different: The former works along with rps_sock_flow_table
>>>> whose CPU info is based on recvmsg by the application. But for the tests
>>>> like what I did, there's no application involved.
>>>>
>>> While rps_sock_flow_table is currently only managed by recvmsg, it
>>> still is the general mechanism that maps flows to CPUs for steering.
>>> There should be nothing preventing you from populating and managing
>>> entries in other ways.
>>
>> Well, even using rps_sock_flow_table to map the sparse flows to CPUs,
>> we still need a data structure to describe a single flow -- that's what
>> struct cpu_flow is doing. Besides, rps_sock_flow_table, by its meaning,
>> does not seem to make sense for our purpose. How about keeping the patch
>> as is but renaming struct cpu_flow to struct rps_sparse_flow? It's like:
>>
>
> sock_flow_table is about mapping a flow (by its rxhash) to cpu.
>
> If you feel 'sock' is bad name, you can rename it.
>
> You dont need adding new data structure and code in fast path.
>
> Only the first packet of a new flow might be handled by 'the wrong cpu'.
>
> If you add code in forward path to change flow_table for next packets,
> added cost in fast path is null.

Did you really read my patch and understand what I commented? When I was
talking about using rps_sparse_flow (initially cpu_flow), neither
rps_sock_flow_table nor rps_dev_flow_table is activated (number of
entries: 0).

FYI below:

On 05/04/2012 11:39 AM, Deng-Cheng Zhu wrote:
 > On 05/04/2012 11:22 AM, Tom Herbert wrote:
 >>> +struct cpu_flow {
 >>> + struct net_device *dev;
 >>> + u32 rxhash;
 >>> + unsigned long ts;
 >>> +};
 >>
 >> This seems like overkill, we already have the rps_flow_table and this
 >> used in accelerated RFS so the device can also take advantage of
 >> steering. Maybe somehow program that table for your sparse flows?
 >
 > In fact I did ever try something different in rps_flow_cnt (except for
 > rps_cpus, the only tunable thing relating to RPS in sysfs, am I
 > missing something?) and found no effect in my tests (iperf between 2
 > PCs via Malta which works as router and uses iptables/NAT+RPS)...


Deng-Cheng
