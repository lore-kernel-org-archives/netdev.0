From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_fastopen unaligned access complaints on
 sparc
Date: Thu, 12 Jan 2017 16:18:52 -0500 (EST)
Message-ID: <20170112.161852.1469407145449781531.davem@davemloft.net>
References: <1c39bf41-4ebf-643a-c6a0-caf98a17a89c@oracle.com>
        <20170112.154143.1940764507974590907.davem@davemloft.net>
        <131ec7b7-5b74-2545-8bf7-92812443a876@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, rob.gardner@oracle.com,
        netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <131ec7b7-5b74-2545-8bf7-92812443a876@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Thu, 12 Jan 2017 12:56:08 -0800

> 
> 
> On 1/12/2017 12:41 PM, David Miller wrote:
>> From: Shannon Nelson <shannon.nelson@oracle.com>
>> Date: Thu, 12 Jan 2017 12:30:38 -0800
>>
>>> On 1/12/2017 12:25 PM, Eric Dumazet wrote:
>>>> On Thu, 2017-01-12 at 13:15 -0700, Rob Gardner wrote:
>>>>
>>>>>
>>>>> I suspect that someplace, somebody is casting val to an int * or
>>>>> something like that.
>>>>
>>>> Then that would be the bug. Can we root cause this please ?
>>>>
>>>>
>>>
>>> Look in net/ipv4/tcp_fastopen.c:tcp_fastopen_cookie_gen() for the line
>>>
>>> 	 struct in6_addr *buf = (struct in6_addr *) tmp.val;
>>
>> Oh yeah, that's it.  I didn't notice that at all.
>>
> 
> It looked to me like swapping the data fields would be the easiest and
> least impactive way to fix this.  I didn't want to mess with the
> logic. I'm certainly open to other suggestions.

Given the nature of the problem, your fix is probably fine.

Eric, any objections?
