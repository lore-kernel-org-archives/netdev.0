From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_fastopen unaligned access complaints on
 sparc
Date: Thu, 12 Jan 2017 15:41:43 -0500 (EST)
Message-ID: <20170112.154143.1940764507974590907.davem@davemloft.net>
References: <cd152a9f-4855-a552-2b45-bd619436a628@oracle.com>
        <1484252733.13165.1.camel@edumazet-glaptop3.roam.corp.google.com>
        <1c39bf41-4ebf-643a-c6a0-caf98a17a89c@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, rob.gardner@oracle.com,
        netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1c39bf41-4ebf-643a-c6a0-caf98a17a89c@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Thu, 12 Jan 2017 12:30:38 -0800

> On 1/12/2017 12:25 PM, Eric Dumazet wrote:
>> On Thu, 2017-01-12 at 13:15 -0700, Rob Gardner wrote:
>>
>>>
>>> I suspect that someplace, somebody is casting val to an int * or
>>> something like that.
>>
>> Then that would be the bug. Can we root cause this please ?
>>
>>
> 
> Look in net/ipv4/tcp_fastopen.c:tcp_fastopen_cookie_gen() for the line
> 
> 	 struct in6_addr *buf = (struct in6_addr *) tmp.val;

Oh yeah, that's it.  I didn't notice that at all.
