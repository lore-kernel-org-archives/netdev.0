From: Glauber Costa <glommer@parallels.com>
Subject: Re: [v3.3-rc1 regression] TCP: too many of orphaned sockets
Date: Fri, 27 Jan 2012 18:28:41 +0400
Message-ID: <4F22B499.6080308@parallels.com>
References: <20120127124641.GA30819@elte.hu> <4F229D5C.4040300@parallels.com> <20120127125645.GA28131@elte.hu> <20120127141754.GA30202@elte.hu> <20120127142246.GA22318@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120127142246.GA22318@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/27/2012 06:22 PM, Ingo Molnar wrote:
>
> * Ingo Molnar<mingo@elte.hu>  wrote:
>
>> ok, i've bisected it, and the bad commit is:
>>
>> 3dc43e3e4d0b52197d3205214fe8f162f9e0c334 is the first bad commit
>> commit 3dc43e3e4d0b52197d3205214fe8f162f9e0c334
>> Author: Glauber Costa<glommer@parallels.com>
>> Date:   Sun Dec 11 21:47:05 2011 +0000
>>
>>      per-netns ipv4 sysctl_tcp_mem
>
> Might be related to this detail in the .config:
>
>   # CONFIG_PROC_SYSCTL is not set
>
> So former tcp_init() code does not get run?
>
> Thanks,
>
> 	Ingo
Yeah, the problem is that the sysctl variables are used internally
even though CONFIG_PROC_SYSCTL is not set. This patch makes the
initialization happen in the per-netns sysctl initializer, so it will 
have bogus values with your config.

Let me send you a test patch shortly.
