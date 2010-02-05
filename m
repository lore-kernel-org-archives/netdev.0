From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port
 numbers
Date: Fri, 05 Feb 2010 12:45:38 +0800
Message-ID: <4B6BA272.4090405@redhat.com>
References: <201002031312.48531.opurdila@ixiacom.com> <201002041444.01897.opurdila@ixiacom.com> <20100204.094110.64247447.davem@davemloft.net> <201002042015.51092.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756044Ab0BEEmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 23:42:20 -0500
In-Reply-To: <201002042015.51092.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> On Thursday 04 February 2010 19:41:10 you wrote:
> 
>> From: Octavian Purdila <opurdila@ixiacom.com>
>> Date: Thu, 4 Feb 2010 14:44:01 +0200
>>
>>> My concern is that we can have multiple applications that require a
>>> fixed port and if those ports are significantly apart we will
>>> decrease the port range available for connect. And that will hurt
>>> the rate of which new connections can be opened.
>> I'm already uneasy about adding the simple check every time
>> we loop around in the bind port allocator.
>>
>> Adding an LSM hook to this spot?  I absolutely refuse to allow
>> that, it will completely kill bind performance.
>>
> 
> I think Tetsuo was proposing the LSM hook, so I'll leave him the daunting task 
> of convincing you of the benefit of that :) - I have no opinion on this due to 
> massive lack of knowledge.
> 
> I was just proposing to use a discrete set of ports instead of a range. The 
> check in the current patch:
> 
> int inet_is_reserved_local_port(int port)
> {
>        int min, max;
> 
>        inet_get_local_reserved_ports(&min, &max);
>        if (min && max)
>                return (port >= min && port <= max);
>        return 0;
> }
> 
> would become:
> 
> int inet_is_reserved_local_port(int port)
> {
> 	if (test_bit(port, reserved_ports))
> 		return 1;
> 	return 0;
> }
> 
> In theory it might be slower because of the reserved_ports bitmap will have a 
> larger memory footprint than just a min/max, especially with random port 
> allocation. But is this an issue in practice?

Again, using bitmap algorithm is not a problem and it's better, the
problem is sysctl interface, how would you plan to interact with users
via sysctl/proc if you use bitmap to handle this? I would like to hear
more details about this.

Thanks!

