From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH] tcp: fix tcp_fastopen unaligned access complaints on
 sparc
Date: Thu, 12 Jan 2017 12:56:08 -0800
Message-ID: <131ec7b7-5b74-2545-8bf7-92812443a876@oracle.com>
References: <cd152a9f-4855-a552-2b45-bd619436a628@oracle.com>
 <1484252733.13165.1.camel@edumazet-glaptop3.roam.corp.google.com>
 <1c39bf41-4ebf-643a-c6a0-caf98a17a89c@oracle.com>
 <20170112.154143.1940764507974590907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, rob.gardner@oracle.com,
        netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170112.154143.1940764507974590907.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 1/12/2017 12:41 PM, David Miller wrote:
> From: Shannon Nelson <shannon.nelson@oracle.com>
> Date: Thu, 12 Jan 2017 12:30:38 -0800
>
>> On 1/12/2017 12:25 PM, Eric Dumazet wrote:
>>> On Thu, 2017-01-12 at 13:15 -0700, Rob Gardner wrote:
>>>
>>>>
>>>> I suspect that someplace, somebody is casting val to an int * or
>>>> something like that.
>>>
>>> Then that would be the bug. Can we root cause this please ?
>>>
>>>
>>
>> Look in net/ipv4/tcp_fastopen.c:tcp_fastopen_cookie_gen() for the line
>>
>> 	 struct in6_addr *buf = (struct in6_addr *) tmp.val;
>
> Oh yeah, that's it.  I didn't notice that at all.
>

It looked to me like swapping the data fields would be the easiest and 
least impactive way to fix this.  I didn't want to mess with the logic. 
I'm certainly open to other suggestions.

sln
