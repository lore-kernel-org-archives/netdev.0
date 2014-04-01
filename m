From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: ipv6:remove ipv6 global address after the interface is down
Date: Tue, 01 Apr 2014 18:12:09 +0800
Message-ID: <533A90F9.3050807@gmail.com>
References: <533A8737.8050108@gmail.com> <20140401093544.GF24150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Paul Gortmaker <paul.gortmaker@windriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140401093544.GF24150@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/01/2014 05:35 PM, Hannes Frederic Sowa wrote:
> On Tue, Apr 01, 2014 at 05:30:31PM +0800, zhuyj wrote:
>> Hi, Paul
>>
>> With kernel 2.6.34.x, the following problem will appear.
>>
>>   TargetA ------------------------- TargetB
>> 3000::1/64 3000::2/64
>>
>>   TargetA
>>     - bring the interface down by doing an "ifconfig eth1 down"
>>     - bring the interface back up by doing an "ifconfig eth1 up"
>>
>> TargetB
>>     - ping6 3000::1
>>        ping6 succeeds the first time
>>     - after bringing the interface on TargetA down and then back up,
>> ping6 to the interface fails.
>>
>> With the latest mainline kernel(3.4+), this problem is resolved. When
>> eth1 is down, ipv6 address and route item are removed.
>> But with kernel 2.6.34.x, when eth1 is down, ipv6 address remains while
>> route item is removed.
>>
>> So when eth1 is up and assign the previous ipv6 address, with 2.6.34.x,
>> some errors will appear. But with latest mainline kernel, it can work well.
>>
>> So I made a patch to fix this problem in kernel 2.6.34.x. Please merge
>> this to kernel2.6.34.x.
> 2.6.34 stable is EOL and won't get updated anymore. If this is problem is also
> present in other, still maintained, stable kernel this would be possible.
Hi, Hannes

It is fortunate. I checked other stable kernel. They can work well. 
Maybe this patch can only fix the problem on 2.6.34.x.

>
> Can you identify the upstream commit which repaired this problem and when it
> got introduced?
commit 73a8bd74 [ipv6:Revert 'administrative down' address handling 
changes] can fix this problem.

Best Regards!
Zhu Yanjun
>
> Thanks,
>
>    Hannes
>
>
